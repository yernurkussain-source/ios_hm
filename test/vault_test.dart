import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:final_project/main.dart';
import 'package:final_project/models/note_item.dart';
import 'package:final_project/state/notes_provider.dart';
import 'package:final_project/state/settings_provider.dart';

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
    final context = tester.element(find.text('Discover'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('vault: save name, add and complete a note', (tester) async {
    final prefs = await disk();
    await tester.pumpWidget(MoodCartApp(prefs: prefs));
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
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
}
