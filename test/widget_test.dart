import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  testWidgets('Root screen shows search, bottom navigation and 3 tabs', (
    tester,
  ) async {
    await tester.pumpWidget(const MoodCartApp());

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Search products'), findsOneWidget);
  });

  testWidgets('Tapping a product opens detail with full data, back pops', (
    tester,
  ) async {
    await tester.pumpWidget(const MoodCartApp());
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
    await tester.pumpWidget(const MoodCartApp());
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
