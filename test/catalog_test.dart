import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/data/catalog.dart';
import 'package:final_project/screens/catalog_screen.dart';

Widget app({bool grid = false}) => MaterialApp(
  home: Scaffold(
    body: CatalogScreen(grid: grid, onOpenProduct: (_) {}),
  ),
);

Future<void> swipeAway(WidgetTester tester, String name) async {
  await tester.drag(find.text(name), const Offset(-600, 0));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('list uses ListView.separated with dividers', (tester) async {
    await tester.pumpWidget(app());
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text(catalog.first.name), findsOneWidget);
    expect(find.byType(Divider), findsWidgets);
  });

  testWidgets('grid is a 2-column GridView without overflow', (tester) async {
    await tester.pumpWidget(app(grid: true));
    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
    expect(delegate.childAspectRatio, 0.72);
    expect(tester.takeException(), isNull); // no RenderFlex overflow
  });

  testWidgets('pull-to-refresh adds a new item at the top', (tester) async {
    await tester.pumpWidget(app());
    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pump(); // start refresh
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('New drop'), findsNothing); // still loading
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final first = find.byType(ListTile).first;
    expect(
      find.descendant(of: first, matching: find.textContaining('New drop #1')),
      findsOneWidget,
    );
  });

  testWidgets('swipe deletes and UNDO restores at the same index', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    final second = catalog[1].name;

    await swipeAway(tester, second);
    expect(find.text(second), findsNothing);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect((tiles[1].title as Text).data, second);
  });

  testWidgets('empty state appears and Reset Catalog restores data', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    for (final p in catalog) {
      await swipeAway(tester, p.name);
    }
    expect(find.text('Catalog is Empty'), findsOneWidget);

    await tester.tap(find.text('Reset Catalog'));
    await tester.pumpAndSettle();
    expect(find.text(catalog.first.name), findsOneWidget);
  });
}
