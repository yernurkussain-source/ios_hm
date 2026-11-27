import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/user_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  /// [users] is null on web, where SQLite isn't available.
  AuthCubit({this._users}) : super(const AuthInitial());

  final UserRepository? _users;

  bool get canRegister => _users != null;

  // Demo account from the lab task; works without the database.
  static const demoEmail = 'student@narxoz.kz';
  static const demoPassword = '123456';
  static const _delay = Duration(milliseconds: 1500);

  static bool _validEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  Future<void> login(String email, String password) async {
    if (state is AuthLoading) return;
    final mail = email.trim().toLowerCase();

    emit(const AuthLoading());
    await Future<void>.delayed(_delay);
    if (isClosed) return;

    if (mail.isEmpty || password.isEmpty) {
      return emit(const AuthError('Enter email and password.'));
    }
    if (mail == demoEmail && password == demoPassword) {
      return emit(AuthSuccess(mail.split('@').first, mail));
    }
    final user = await _users?.authenticate(mail, password);
    if (isClosed) return;
    emit(
      user == null
          ? const AuthError('Wrong email or password.')
          : AuthSuccess(user.name, user.email),
    );
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String confirm,
  ) async {
    if (state is AuthLoading) return;
    final users = _users;
    final mail = email.trim().toLowerCase();
    final cleanName = name.trim();

    final problem = switch (true) {
      _ when users == null => 'Sign up needs the mobile app (SQLite).',
      _ when cleanName.isEmpty => 'Enter your name.',
      _ when !_validEmail(mail) => 'Enter a valid email.',
      _ when mail == demoEmail => 'This email is already registered.',
      _ when password.length < 6 => 'Password must be at least 6 characters.',
      _ when password != confirm => 'Passwords do not match.',
      _ => null,
    };
    if (problem != null) {
      // Equatable skips a state equal to the current one; reset first so the
      // same error shows its SnackBar again.
      emit(const AuthInitial());
      return emit(AuthError(problem));
    }

    emit(const AuthLoading());
    try {
      final user = await users!.register(cleanName, mail, password);
      if (isClosed) return;
      emit(AuthSuccess(user.name, user.email));
    } on EmailTakenException {
      if (isClosed) return;
      emit(const AuthError('This email is already registered.'));
    }
  }

  void logout() => emit(const AuthInitial());
}
