import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/blocs/auth_cubit.dart';
import 'package:final_project/blocs/auth_state.dart';
import 'package:final_project/blocs/cart_bloc.dart';
import 'package:final_project/blocs/cart_event.dart';
import 'package:final_project/data/catalog.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:final_project/screens/root_screen.dart';
import 'package:final_project/state/cart_provider.dart';

import 'widget_test.dart' show freshApp, pumpSignedIn;

void main() {
  test('Equatable: states are compared by value', () {
    expect(const AuthError('a'), const AuthError('a'));
    expect(const AuthError('a'), isNot(const AuthError('b')));
    expect(const AuthSuccess('s', 'e'), isNot(const AuthSuccess('s', 'x')));
  });

  test('login emits Loading then Success or Error', () async {
    final cubit = AuthCubit();
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.login('', '');
    await cubit.login('student@narxoz.kz', 'wrong');
    await cubit.login(' Student@narxoz.kz ', '123456');
    await Future<void>.delayed(Duration.zero);

    expect(states, const [
      AuthLoading(),
      AuthError('Enter email and password.'),
      AuthLoading(),
      AuthError('Wrong email or password.'),
      AuthLoading(),
      AuthSuccess('student', 'student@narxoz.kz'),
    ]);
    await sub.cancel();
    await cubit.close();
  });

  test('CartBloc handles events and outside changes', () async {
    final repository = CartProvider();
    final bloc = CartBloc(repository);
    Future<void> send(CartEvent event) {
      bloc.add(event);
      return Future<void>.delayed(Duration.zero);
    }

    await send(AddProductEvent(catalog[0]));
    await send(AddProductEvent(catalog[0]));
    await send(AddProductEvent(catalog[1]));
    expect(bloc.state.count, 3);
    expect(bloc.state.totalPrice, catalog[0].price * 2 + catalog[1].price);

    await send(ChangeQuantityEvent(catalog[0].id, -1));
    await send(RemoveProductEvent(catalog[1].id));
    expect(bloc.state.items, {catalog[0].id: 1});

    repository.add(catalog[2]); // product page / checkout path
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.count, 2);

    await send(const ClearCartEvent());
    expect(bloc.state.items, isEmpty);
    expect(bloc.state.totalPrice, 0);
    await bloc.close();
    repository.add(catalog[0]); // closed bloc no longer listens
  });

  testWidgets('wrong login: spinner, red SnackBar, stays on login', (
    tester,
  ) async {
    await tester.pumpWidget(await freshApp());
    await tester.enterText(find.byType(TextField).first, 'a@b.kz');
    await tester.enterText(find.byType(TextField).last, 'nope');
    await tester.tap(find.text('Log in'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Log in'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 300));
    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.backgroundColor, Colors.red);
    expect(bar.behavior, SnackBarBehavior.floating);
    expect(find.text('Wrong email or password.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('correct login opens the Catalog and removes login', (
    tester,
  ) async {
    await tester.pumpWidget(await freshApp());
    await tester.enterText(find.byType(TextField).first, AuthCubit.demoEmail);
    await tester.enterText(find.byType(TextField).last, AuthCubit.demoPassword);
    await tester.tap(find.text('Log in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(
      tester.widget<RootScreen>(find.byType(RootScreen)).initialTab,
      RootScreen.catalogTab,
    );
    expect(find.byTooltip('Add to Cart'), findsWidgets);
  });

  testWidgets('log out returns to the login screen', (tester) async {
    await pumpSignedIn(tester, await freshApp(), tab: 'Profile');
    await tester.ensureVisible(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(RootScreen), findsNothing);
    expect(find.text('Log in'), findsOneWidget);
  });
}
