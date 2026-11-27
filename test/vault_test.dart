import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:final_project/data/catalog.dart';
import 'package:final_project/main.dart';
import 'package:final_project/models/coins.dart';
import 'package:final_project/models/note_item.dart';
import 'package:final_project/models/product.dart';
import 'package:final_project/state/cart_provider.dart';
import 'package:final_project/state/notes_provider.dart';
import 'package:final_project/state/settings_provider.dart';
import 'package:final_project/state/shop_state.dart';

import 'widget_test.dart' show pumpSignedIn;

Future<SharedPreferences> disk([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  test('NoteItem JSON round trip and fallbacks', () {
    const note = NoteItem(
      id: '1',
      title: 'Buy milk',
      dateText: '20.11.2026 10:00',
      isCompleted: true,
    );
    final back = NoteItem.fromJson(
      jsonDecode(jsonEncode(note.toJson())) as Map<String, dynamic>,
    );
    expect(back.title, 'Buy milk');
    expect(back.isCompleted, isTrue);

    final empty = NoteItem.fromJson({});
    expect(empty.title, '');
    expect(empty.isCompleted, isFalse);
  });

  test('settings use fallbacks and survive a restart', () async {
    final prefs = await disk();
    final settings = SettingsProvider(prefs);
    expect(settings.darkMode, isFalse);
    expect(settings.displayName, 'Guest User');

    await settings.setDarkMode(true);
    await settings.saveName('  Azamat ');
    expect(prefs.getBool('app_theme_dark_mode'), isTrue);
    expect(prefs.getString('user_display_name'), 'Azamat');

    final afterRestart = SettingsProvider(prefs); // new object, same disk
    expect(afterRestart.darkMode, isTrue);
    expect(afterRestart.displayName, 'Azamat');
  });

  test('notes: add prepends, toggle and delete sync to disk', () async {
    final prefs = await disk();
    final notes = NotesProvider(prefs);
    await notes.add('First', now: DateTime(2026, 11, 20, 9, 5));
    await notes.add('Second', now: DateTime(2026, 11, 20, 9, 6));
    expect(notes.notes.map((n) => n.title), ['Second', 'First']);
    expect(notes.notes.last.dateText, '20.11.2026 09:05');

    await notes.toggle(notes.notes.first.id);
    final saved = jsonDecode(prefs.getString('notes_items')!) as List;
    expect(saved.first['isCompleted'], isTrue);

    final afterRestart = NotesProvider(prefs);
    expect(afterRestart.notes.first.isCompleted, isTrue);
    expect(afterRestart.notes, hasLength(2));

    await afterRestart.delete(afterRestart.notes.last.id);
    expect(NotesProvider(prefs).notes.single.title, 'Second');
  });

  test('corrupted notes JSON starts empty instead of crashing', () async {
    final prefs = await disk({'notes_items': 'not json'});
    expect(NotesProvider(prefs).notes, isEmpty);
  });

  testWidgets('app opens dark on the first frame when saved', (tester) async {
    final prefs = await disk({'app_theme_dark_mode': true});
    await tester.pumpWidget(MoodCartApp(prefs: prefs));
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    final context = tester.element(find.text('Log in'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('vault: save name, add and complete a note', (tester) async {
    final prefs = await disk();
    await pumpSignedIn(tester, MoodCartApp(prefs: prefs), tab: 'Profile');
    await tester.ensureVisible(find.text('Notes & Settings Vault'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notes & Settings Vault'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Guest User 👋'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Azamat');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Azamat 👋'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Prepare defense');
    await tester.tap(find.byTooltip('Add note'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(NotesProvider(prefs).notes.single.isCompleted, isTrue);
  });

  test('Week 9 + 11: cart provider survives a restart', () async {
    final prefs = await disk();
    CartProvider(prefs)
      ..add(catalog[0], quantity: 2)
      ..add(catalog[1])
      ..remove(catalog[1].id);

    final afterRestart = CartProvider(prefs);
    expect(afterRestart.items, {catalog[0].id: 2});
    expect(afterRestart.total, catalog[0].price * 2);

    afterRestart.clear();
    expect(CartProvider(prefs).items, isEmpty);
  });

  test('saved cart drops unknown ids and survives bad JSON', () async {
    final known = catalog[0].id;
    var prefs = await disk({'cart_items': '{"$known": 1, "999999": 3}'});
    expect(CartProvider(prefs).items, {known: 1});

    prefs = await disk({'cart_items': 'broken'});
    expect(CartProvider(prefs).items, isEmpty);
  });

  testWidgets('saved cart shows in the AppBar badge on launch', (tester) async {
    final prefs = await disk({'cart_items': '{"${catalog[0].id}": 3}'});
    await pumpSignedIn(tester, MoodCartApp(prefs: prefs));
    expect(find.text('3'), findsOneWidget);
  });

  /// A product that only exists after an API call (not in the local catalog).
  Product cloudProduct() => Product.fromJson({
    'id': 7777,
    'title': 'Cloud Jacket',
    'price': 50,
    'category': "men's clothing",
    'image': 'https://example.com/j.png',
    'rating': {'rate': 4.5, 'count': 10},
  });

  test('cart keeps Cloud (API) products after a cold start', () async {
    final prefs = await disk();
    final jacket = cloudProduct();
    registerProducts([jacket]);
    CartProvider(prefs).add(jacket, quantity: 2);

    generatedProducts.clear(); // new process: nothing in memory
    final afterRestart = CartProvider(prefs);
    expect(afterRestart.items, {7777: 2});
    expect(afterRestart.total, 50.0 * Product.kztPerUsd * 2);
  });

  test('coins, level, missions, history and favorites survive', () async {
    final prefs = await disk();
    final now = DateTime(2026, 11, 21, 10);
    final jacket = cloudProduct();
    registerProducts([jacket]);

    final shop = ShopState(clock: () => now, prefs: prefs);
    shop.checkIn(); // +5
    shop.toggleFavorite(catalog[0]);
    shop.toggleFavorite(jacket);
    final mission = Mission.all.firstWhere((m) => m.id == 'first_fav');
    shop.claimMission(mission); // +10

    generatedProducts.clear();
    final again = ShopState(clock: () => now, prefs: prefs);
    expect(again.coins, 15);
    expect(again.lifetimeCoins, 15);
    expect(again.checkedInToday, isTrue);
    expect(again.isClaimed(mission), isTrue);
    expect(again.history.map((e) => e.amount), [10, 5]);
    expect(again.favorites.map((p) => p.id), [catalog[0].id, 7777]);
  });

  testWidgets('cold launch restores cart badge, coins and favorites badge', (
    tester,
  ) async {
    final prefs = await disk({
      'cart_items': '{"${catalog[0].id}": 2}',
      'shop_state': '{"coins": 42, "favorites": [${catalog[1].id}]}',
    });
    await pumpSignedIn(tester, MoodCartApp(prefs: prefs));
    expect(find.text('2'), findsOneWidget); // cart badge
    expect(find.text('42'), findsOneWidget); // coin pill
    expect(find.text('1'), findsOneWidget); // favorites badge
  });
}
