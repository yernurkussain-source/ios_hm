import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_item.dart';

/// LAB 11: the whole note list is saved as one JSON string.
class NotesProvider extends ChangeNotifier {
  static const notesKey = 'notes_items';

  final SharedPreferences _prefs;
  final List<NoteItem> _notes;

  NotesProvider(this._prefs) : _notes = _load(_prefs);

  List<NoteItem> get notes => List.unmodifiable(_notes);

  static List<NoteItem> _load(SharedPreferences prefs) {
    final raw = prefs.getString(notesKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => NoteItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return []; // corrupted data: start empty instead of crashing
    } on TypeError {
      return [];
    }
  }

  Future<void> _save() async {
    notifyListeners();
    final json = jsonEncode(_notes.map((n) => n.toJson()).toList());
    await _prefs.setString(notesKey, json);
  }

  Future<void> add(String title, {DateTime? now}) {
    final time = now ?? DateTime.now();
    _notes.insert(
      0, // prepend: newest on top
      NoteItem(
        id: time.microsecondsSinceEpoch.toString(),
        title: title.trim(),
        dateText: _format(time),
      ),
    );
    return _save();
  }

  Future<void> toggle(String id) {
    final i = _notes.indexWhere((n) => n.id == id);
    _notes[i] = _notes[i].copyWith(isCompleted: !_notes[i].isCompleted);
    return _save();
  }

  Future<void> delete(String id) {
    _notes.removeWhere((n) => n.id == id);
    return _save();
  }

  static String _format(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}
