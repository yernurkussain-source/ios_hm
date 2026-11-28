import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/diary_entry.dart';
import '../state/diary_provider.dart';
import '../theme/app_theme.dart';

/// LAB 13: Narxoz Geotagged Photo Diary.
class PhotoDiaryScreen extends StatefulWidget {
  const PhotoDiaryScreen({super.key});

  @override
  State<PhotoDiaryScreen> createState() => _PhotoDiaryScreenState();
}

class _PhotoDiaryScreenState extends State<PhotoDiaryScreen> {
  final caption = TextEditingController();
  String? photoPath;
  Position? position;
  DateTime? takenAt;
  bool locating = false;

  @override
  void dispose() {
    caption.dispose();
    super.dispose();
  }

  void toast(String text, {SnackBarAction? action, bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          action: action,
          persist: false,
          backgroundColor: error ? Colors.red : null,
        ),
      );
  }

  // ---------- Task 2: camera & gallery ----------

  Future<void> pickPhoto(ImageSource source) async {
    // Android: CAMERA is declared in the manifest, so it must be granted
    // before the camera opens. iOS asks by itself (NSCameraUsageDescription).
    final android = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (source == ImageSource.camera && android) {
      final status = await Permission.camera.request();
      if (!mounted) return;
      if (status.isPermanentlyDenied) {
        // "Don't ask again": the system dialog never shows again.
        return toast(
          'Camera is blocked. Allow it in Settings.',
          action: SnackBarAction(label: 'SETTINGS', onPressed: openAppSettings),
        );
      }
      if (!status.isGranted) return toast('Camera permission denied.');
    }

    final XFile? file;
    try {
      file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80, // JPEG compression
        maxWidth: 1080, // resize big photos
      );
    } on Exception {
      if (mounted) toast('Could not open the camera or gallery.', error: true);
      return;
    }
    if (file == null || !mounted) return; // user cancelled
    setState(() {
      photoPath = file!.path;
      takenAt = DateTime.now();
    });
    unawaited(fetchLocation()); // geotag automatically after capture
  }

  void choosePhotoSource() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(sheet);
                pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pick from Gallery'),
              onTap: () {
                Navigator.pop(sheet);
                pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Task 1 + 3: permissions & GPS ----------

  Future<void> fetchLocation() async {
    if (locating) return;
    setState(() => locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) await _askToEnableGps();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        return toast('Location permission denied. Entry saves without GPS.');
      }
      if (permission == LocationPermission.deniedForever) {
        return toast(
          'Location is blocked. Allow it in Settings.',
          action: SnackBarAction(
            label: 'SETTINGS',
            onPressed: Geolocator.openAppSettings,
          ),
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (mounted) setState(() => position = pos);
    } on TimeoutException {
      if (mounted) toast('No GPS signal. Try near a window.', error: true);
    } on Exception catch (e) {
      if (mounted) toast('Location error: $e', error: true);
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  Future<void> _askToEnableGps() => showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      icon: const Icon(Icons.location_off_outlined),
      title: const Text('GPS is turned off'),
      content: const Text('Turn on location services to geotag your photo.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog),
          child: const Text('Not now'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () {
            Navigator.pop(dialog);
            Geolocator.openLocationSettings();
          },
          child: const Text('Open settings'),
        ),
      ],
    ),
  );

  // ---------- Task 4: save to diary ----------

  /// image_picker returns a cache file the OS may delete; keep a copy in the
  /// app's own folder.
  Future<String> _keepPhoto(String path) async {
    // shortcut: on web the path is a blob URL that dies on reload.
    if (kIsWeb) return path;
    final dir = await getApplicationDocumentsDirectory();
    final name =
        'diary_${DateTime.now().millisecondsSinceEpoch}${p.extension(path)}';
    return (await File(path).copy(p.join(dir.path, name))).path;
  }

  Future<void> save() async {
    final path = photoPath;
    if (path == null) return toast('Take or pick a photo first.');
    final text = caption.text.trim();
    if (text.isEmpty) return toast('Write a caption.');

    final kept = await _keepPhoto(path);
    if (!mounted) return;
    final pos = position;
    await context.read<DiaryProvider>().add(
      DiaryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        photoPath: kept,
        caption: text,
        timestamp: takenAt ?? DateTime.now(),
        latitude: pos?.latitude,
        longitude: pos?.longitude,
        accuracy: pos?.accuracy,
        altitude: pos?.altitude,
      ),
    );
    if (!mounted) return;
    setState(() {
      photoPath = null;
      position = null;
      takenAt = null;
      caption.clear();
    });
    FocusScope.of(context).unfocus();
    toast('Saved to diary');
  }

  Future<void> deleteEntry(DiaryEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: Text('"${entry.caption}" and its photo will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<DiaryProvider>().delete(entry.id);
    // Free the space too; the copy lives in our own folder.
    if (!kIsWeb) {
      try {
        await File(entry.photoPath).delete();
      } on FileSystemException {
        // Already gone: nothing to clean up.
      }
    }
    if (mounted) toast('Entry deleted');
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<DiaryProvider>().entries;
    final pal = context.palette;
    final pos = position;

    return Scaffold(
      appBar: AppBar(title: const Text('Photo Journal')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          // Preview box.
          GestureDetector(
            onTap: choosePhotoSource,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 260,
                color: pal.neutralSoft,
                child: photoPath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_outlined,
                            size: 56,
                            color: pal.muted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No photo yet',
                            style: TextStyle(color: pal.muted),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          LocalImage(photoPath!, fit: BoxFit.cover),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: IconButton.filled(
                              tooltip: 'Remove photo',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => setState(() {
                                photoPath = null;
                                position = null;
                                takenAt = null;
                              }),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // GPS readout.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: locating
                  ? const Row(
                      children: [
                        SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        SizedBox(width: 12),
                        Text('Getting GPS lock…'),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          Icons.place_outlined,
                          'Latitude',
                          pos?.latitude.toStringAsFixed(6),
                        ),
                        _InfoRow(
                          Icons.place_outlined,
                          'Longitude',
                          pos?.longitude.toStringAsFixed(6),
                        ),
                        _InfoRow(
                          Icons.gps_fixed,
                          'Accuracy',
                          pos == null
                              ? null
                              : '± ${pos.accuracy.toStringAsFixed(1)} m',
                        ),
                        _InfoRow(
                          Icons.terrain_outlined,
                          'Altitude',
                          pos == null
                              ? null
                              : '${pos.altitude.toStringAsFixed(1)} m',
                        ),
                        _InfoRow(
                          Icons.schedule,
                          'Timestamp',
                          takenAt == null
                              ? null
                              : DiaryEntry.formatTime(takenAt!),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => pickPhoto(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Take Photo'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => pickPhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: locating ? null : fetchLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Fetch Current GPS Location'),
          ),
          const Divider(height: 36),

          TextField(
            controller: caption,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Caption, e.g. Campus Quad at Narxoz',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Entry to Diary'),
          ),
          const SizedBox(height: 28),

          Text(
            'Diary Entries (${entries.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Your saved moments will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: pal.muted),
              ),
            ),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox.square(
                      dimension: 64,
                      // cacheWidth: decode a small bitmap for the thumbnail.
                      child: LocalImage(
                        e.photoPath,
                        fit: BoxFit.cover,
                        cacheWidth: 200,
                      ),
                    ),
                  ),
                  title: Text(
                    e.caption,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${e.hasLocation ? DiaryEntry.formatCoordinates(e.latitude!, e.longitude!) : 'No location'}\n'
                    '${DiaryEntry.formatTime(e.timestamp)}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Delete entry',
                    onPressed: () => deleteEntry(e),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(color: context.palette.muted)),
          ),
          Text(
            value ?? '—',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Image.file on phones; on web image_picker gives a blob URL instead.
class LocalImage extends StatelessWidget {
  final String path;
  final BoxFit? fit;
  final int? cacheWidth;

  const LocalImage(this.path, {super.key, this.fit, this.cacheWidth});

  @override
  Widget build(BuildContext context) {
    Widget broken(_, _, _) => const Center(child: Icon(Icons.broken_image));
    return kIsWeb
        ? Image.network(
            path,
            fit: fit,
            cacheWidth: cacheWidth,
            errorBuilder: broken,
          )
        : Image.file(
            File(path),
            fit: fit,
            cacheWidth: cacheWidth,
            errorBuilder: broken,
          );
  }
}
