import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:final_project/main.dart';
import 'package:final_project/models/diary_entry.dart';
import 'package:final_project/screens/photo_diary_screen.dart';
import 'package:final_project/state/diary_provider.dart';

import 'widget_test.dart' show pumpSignedIn;

Future<SharedPreferences> disk([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  test('coordinates and time are formatted like the task mockup', () {
    expect(
      DiaryEntry.formatCoordinates(43.238949, 76.889709),
      '43.2389° N, 76.8897° E',
    );
    expect(
      DiaryEntry.formatCoordinates(-33.86, -151.2),
      '33.8600° S, 151.2000° W',
    );
    expect(
      DiaryEntry.formatTime(DateTime(2026, 11, 24, 14, 30, 15)),
      '2026-11-24 14:30:15',
    );
  });

  test('entry JSON round trip; missing GPS stays null', () {
    final entry = DiaryEntry(
      id: '1',
      photoPath: '/data/diary_1.jpg',
      caption: 'Campus Quad',
      timestamp: DateTime(2026, 11, 24, 14, 30, 15),
      latitude: 43.238949,
      longitude: 76.889709,
      accuracy: 12.4,
    );
    final back = DiaryEntry.fromJson(
      jsonDecode(jsonEncode(entry.toJson())) as Map<String, dynamic>,
    );
    expect(back.caption, 'Campus Quad');
    expect(back.latitude, 43.238949);
    expect(back.accuracy, 12.4);
    expect(back.timestamp, entry.timestamp);

    final noGps = DiaryEntry.fromJson({'id': '2', 'caption': 'Indoor'});
    expect(noGps.hasLocation, isFalse);
  });

  test('diary survives a restart, newest entry first', () async {
    final prefs = await disk();
    final diary = DiaryProvider(prefs);
    for (final c in ['First', 'Second']) {
      await diary.add(
        DiaryEntry(
          id: c,
          photoPath: '/p/$c.jpg',
          caption: c,
          timestamp: DateTime(2026),
        ),
      );
    }
    expect(DiaryProvider(prefs).entries.map((e) => e.caption), [
      'Second',
      'First',
    ]);
  });

  testWidgets('diary screen: placeholder, empty GPS and saved entries', (
    tester,
  ) async {
    final saved = DiaryEntry(
      id: '1',
      photoPath: '/missing.jpg',
      caption: 'Campus Quad',
      timestamp: DateTime(2026, 11, 24, 14, 30, 15),
      latitude: 43.238949,
      longitude: 76.889709,
    );
    final prefs = await disk({
      'photo_diary': jsonEncode([saved.toJson()]),
    });
    await pumpSignedIn(tester, MoodCartApp(prefs: prefs), tab: 'Profile');
    await tester.ensureVisible(find.text('Photo Diary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Photo Diary'));
    await tester.pumpAndSettle();

    expect(find.byType(PhotoDiaryScreen), findsOneWidget);
    expect(find.text('No photo yet'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(5)); // no GPS yet

    final list = find
        .descendant(
          of: find.byType(PhotoDiaryScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    Future<void> scrollTo(Finder f) =>
        tester.scrollUntilVisible(f, 200, scrollable: list);

    // Save without a photo is refused, nothing crashes.
    await scrollTo(find.text('Save Entry to Diary'));
    await tester.tap(find.text('Save Entry to Diary'));
    await tester.pump();
    expect(find.text('Take or pick a photo first.'), findsOneWidget);

    await scrollTo(find.text('Campus Quad'));
    expect(find.textContaining('43.2389° N, 76.8897° E'), findsOneWidget);
    expect(find.textContaining('2026-11-24 14:30:15'), findsOneWidget);
  });
}
