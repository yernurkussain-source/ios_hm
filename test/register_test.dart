import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:final_project/blocs/auth_cubit.dart';
import 'package:final_project/blocs/auth_state.dart';
import 'package:final_project/main.dart';
import 'package:final_project/screens/register_screen.dart';
import 'package:final_project/services/user_repository.dart';

/// A fresh SQLite database in memory (runs on the PC, no emulator needed).
UserRepository memoryRepo() =>
    UserRepository(factory: databaseFactoryFfi, path: inMemoryDatabasePath);

/// Collects every state the cubit emits while [action] runs.
Future<List<AuthState>> statesOf(
  AuthCubit cubit,
  Future<void> Function() action,
) async {
  final states = <AuthState>[];
  final sub = cubit.stream.listen(states.add);
  await action();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

void main() {
  setUpAll(sqfliteFfiInit);

  group('UserRepository (SQLite)', () {
    test('register, then log in only with the right password', () async {
      final repo = memoryRepo();
      await repo.register('Azamat', 'aza@mail.kz', 'secret1');

      final user = await repo.authenticate('aza@mail.kz', 'secret1');
      expect(user?.name, 'Azamat');
      expect(await repo.authenticate('aza@mail.kz', 'wrong'), isNull);
      expect(await repo.authenticate('nobody@mail.kz', 'secret1'), isNull);
      await repo.close();
    });

    test('the same email cannot register twice', () async {
      final repo = memoryRepo();
      await repo.register('A', 'a@mail.kz', 'secret1');
      await expectLater(
        repo.register('B', 'a@mail.kz', 'other12'),
        throwsA(isA<EmailTakenException>()),
      );
      await repo.close();
    });

    test('the password itself is never stored', () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      // Same database file for repo and the raw query below.
      final repo = UserRepository(
        factory: _FixedFactory(db),
        path: inMemoryDatabasePath,
      );
      await db.execute('''
        CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL, email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL, salt TEXT NOT NULL,
          created_at TEXT NOT NULL)''');
      await repo.register('A', 'a@mail.kz', 'secret1');
      await repo.register('B', 'b@mail.kz', 'secret1');

      final rows = await db.query('users');
      for (final row in rows) {
        expect(row.values.join(' '), isNot(contains('secret1')));
      }
      // Same password, different salt → different hash.
      expect(rows[0]['password_hash'], isNot(rows[1]['password_hash']));
      await db.close();
    });
  });

  group('AuthCubit.register', () {
    test('validation errors come before any database call', () async {
      final cubit = AuthCubit(users: memoryRepo());
      Future<String?> errorFor(String n, String e, String p, String c) async {
        final states = await statesOf(cubit, () => cubit.register(n, e, p, c));
        final last = states.last;
        return last is AuthError ? last.message : null;
      }

      expect(
        await errorFor('', 'a@b.kz', '123456', '123456'),
        'Enter your name.',
      );
      expect(
        await errorFor('A', 'not-an-email', '123456', '123456'),
        'Enter a valid email.',
      );
      expect(
        await errorFor('A', 'a@b.kz', '123', '123'),
        'Password must be at least 6 characters.',
      );
      expect(
        await errorFor('A', 'a@b.kz', '123456', '654321'),
        'Passwords do not match.',
      );
      // Same error twice still emits (so the SnackBar shows again).
      expect(
        await errorFor('A', 'a@b.kz', '123456', '654321'),
        'Passwords do not match.',
      );
      expect(
        await errorFor('A', AuthCubit.demoEmail, '123456', '123456'),
        'This email is already registered.',
      );
      await cubit.close();
    });

    test('sign up succeeds, duplicate fails, then login works', () async {
      final cubit = AuthCubit(users: memoryRepo());

      var states = await statesOf(
        cubit,
        () => cubit.register(' Azamat ', 'Aza@Mail.kz', 'secret1', 'secret1'),
      );
      expect(states, const [
        AuthLoading(),
        AuthSuccess('Azamat', 'aza@mail.kz'),
      ]);

      states = await statesOf(
        cubit,
        () => cubit.register('X', 'aza@mail.kz', 'secret2', 'secret2'),
      );
      expect(states.last, const AuthError('This email is already registered.'));

      cubit.logout();
      states = await statesOf(
        cubit,
        () => cubit.login('aza@mail.kz', 'secret1'),
      );
      expect(states.last, const AuthSuccess('Azamat', 'aza@mail.kz'));
      await cubit.close();
    });

    test('without SQLite (web) sign up is not available', () async {
      final cubit = AuthCubit();
      expect(cubit.canRegister, isFalse);
      final states = await statesOf(
        cubit,
        () => cubit.register('A', 'a@b.kz', '123456', '123456'),
      );
      expect(states.last, isA<AuthError>());
      await cubit.close();
    });
  });

  testWidgets('register screen shows a red SnackBar on a bad form', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MoodCartApp(prefs: prefs, users: memoryRepo()));

    await tester.tap(find.text('No account? Create one'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Azamat');
    await tester.enterText(fields.at(1), 'aza@mail.kz');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'different');
    await tester.tap(find.text('Sign up'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Passwords do not match.'), findsOneWidget);
    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.backgroundColor, Colors.red);
  });
}

/// Hands the repository an already-open database (to inspect raw rows).
class _FixedFactory implements DatabaseFactory {
  _FixedFactory(this.db);
  final Database db;

  @override
  Future<Database> openDatabase(String path, {OpenDatabaseOptions? options}) =>
      Future.value(db);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
