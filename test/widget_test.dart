import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:final_project/blocs/auth_cubit.dart';
import 'package:final_project/main.dart';
import 'package:final_project/screens/product_detail_screen.dart';

/// Scrolls the feed until the product card is visible, then taps it.
Future<void> openProduct(WidgetTester tester, String name) async {
  final feed = find
      .descendant(
        of: find.byKey(const PageStorageKey('feedScroll')),
        matching: find.byType(Scrollable),
      )
      .first;
  final card = find.text(name);
  await tester.scrollUntilVisible(card, 150, scrollable: feed);
  await tester.tap(card);
  await tester.pumpAndSettle();
}

/// In-memory SharedPreferences, like a fresh install.
Future<MoodCartApp> freshApp() async {
  SharedPreferences.setMockInitialValues({});
  return MoodCartApp(prefs: await SharedPreferences.getInstance());
}

/// Pumps the app, logs in with the demo account and opens [tab].
Future<void> pumpSignedIn(
  WidgetTester tester,
  MoodCartApp app, {
  String tab = 'Feed',
}) async {
  await tester.pumpWidget(app);
  await tester.enterText(find.byType(TextField).first, AuthCubit.demoEmail);
  await tester.enterText(find.byType(TextField).last, AuthCubit.demoPassword);
  await tester.tap(find.text('Log in'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1600));
  await tester.pumpAndSettle();
  await tester.tap(find.text(tab).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Root screen shows search, bottom navigation and 3 tabs', (
    tester,
  ) async {
    await pumpSignedIn(tester, await freshApp());

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Search products'), findsOneWidget);
  });

  testWidgets('Tapping a product opens detail with full data, back pops', (
    tester,
  ) async {
    await pumpSignedIn(tester, await freshApp());
    await openProduct(tester, 'Focus Headphones');

    final detailList = find
        .descendant(
          of: find.byType(ProductDetailScreen),
          matching: find.byType(Scrollable),
        )
        .first;

    // Complete object reached the detail screen.
    expect(find.byType(ProductDetailScreen), findsOneWidget);
    expect(find.text('24 990 ₸'), findsWidgets);
    await tester.scrollUntilVisible(
      find.textContaining('Comfortable wireless headphones'),
      200,
      scrollable: detailList,
    );

    // In-body back button.
    await tester.fling(detailList, const Offset(0, -1000), 2000);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Products'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailScreen), findsNothing);
    // Feed state (scroll position) survived the round trip.
    expect(find.text('Focus Headphones'), findsOneWidget);

    // AppBar back icon.
    await openProduct(tester, 'Focus Headphones');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailScreen), findsNothing);
  });

  testWidgets('Favorite added on detail survives pop and shows in tab 2', (
    tester,
  ) async {
    await pumpSignedIn(tester, await freshApp());
    await openProduct(tester, 'Focus Headphones');

    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pump();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 saved for later'), findsOneWidget);
  });
}
