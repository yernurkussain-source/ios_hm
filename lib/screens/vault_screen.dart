import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/notes_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme.dart';

/// LAB 11: Offline-First Notes & Settings Vault.
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  late final nameController = TextEditingController(
    text: _savedName(context.read<SettingsProvider>().displayName),
  );
  final noteController = TextEditingController();

  // Leave the field empty (hint shows) when the fallback name is in use.
  static String _savedName(String name) =>
      name == SettingsProvider.defaultName ? '' : name;

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void saveName() {
    context.read<SettingsProvider>().saveName(nameController.text);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Name saved')));
  }

  void addNote() {
    final title = noteController.text.trim();
    if (title.isEmpty) return;
    context.read<NotesProvider>().add(title);
    noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final notesProvider = context.watch<NotesProvider>();
    final notes = notesProvider.notes;
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('Vault')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          // Header: loaded name or 'Guest User'.
          Text(
            'Hello, ${settings.displayName} 👋',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Everything here is saved on this device.',
            style: TextStyle(color: p.muted),
          ),
          const SizedBox(height: 20),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark mode'),
              subtitle: const Text('Remembered after restart'),
              value: settings.darkMode,
              onChanged: settings.setDarkMode,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => saveName(),
                      decoration: const InputDecoration(
                        hintText: 'Your name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 52),
                    ),
                    onPressed: saveName,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'Notes (${notes.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: noteController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => addNote(),
                  decoration: const InputDecoration(
                    hintText: 'Write a note…',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                tooltip: 'Add note',
                iconSize: 26,
                onPressed: addNote,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (notes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No notes yet. Add one — it will survive a restart.',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.muted),
              ),
            ),
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: Checkbox(
                    value: note.isCompleted,
                    onChanged: (_) => notesProvider.toggle(note.id),
                  ),
                  title: Text(
                    note.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: note.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: note.isCompleted ? p.muted : p.ink,
                    ),
                  ),
                  subtitle: Text(note.dateText),
                  trailing: IconButton(
                    tooltip: 'Delete note',
                    onPressed: () => notesProvider.delete(note.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
