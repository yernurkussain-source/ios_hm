import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/diary_entry.dart';

/// LAB 13: diary metadata saved offline as one JSON string (same idea as the
/// Lab 11 notes). The photos themselves are files in the app folder.
class DiaryProvider extends ChangeNotifier {
  static const diaryKey = 'photo_diary';

  final SharedPreferences _prefs;
  final List<DiaryEntry> _entries;

  DiaryProvider(this._prefs) : _entries = _load(_prefs);

  List<DiaryEntry> get entries => List.unmodifiable(_entries);

  static List<DiaryEntry> _load(SharedPreferences prefs) {
    final raw = prefs.getString(diaryKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> add(DiaryEntry entry) {
    _entries.insert(0, entry); // newest first
    return _save();
  }

  Future<void> delete(String id) {
    _entries.removeWhere((e) => e.id == id);
    return _save();
  }

  Future<void> _save() async {
    notifyListeners();
    await _prefs.setString(
      diaryKey,
      jsonEncode(_entries.map((e) => e.toJson()).toList()),
    );
  }
}
