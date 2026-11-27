/// LAB 13: one geotagged photo. Location fields are null when GPS was not
/// available or the user denied the permission.
class DiaryEntry {
  final String id;
  final String photoPath;
  final String caption;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final double? altitude;
  final DateTime timestamp;

  const DiaryEntry({
    required this.id,
    required this.photoPath,
    required this.caption,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.altitude,
  });

  bool get hasLocation => latitude != null && longitude != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'photoPath': photoPath,
    'caption': caption,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'altitude': altitude,
    'timestamp': timestamp.toIso8601String(),
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    id: json['id'] as String? ?? '',
    photoPath: json['photoPath'] as String? ?? '',
    caption: json['caption'] as String? ?? '',
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    accuracy: (json['accuracy'] as num?)?.toDouble(),
    altitude: (json['altitude'] as num?)?.toDouble(),
    timestamp:
        DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime(2000),
  );

  /// 43.238949, 76.889709 → "43.2389° N, 76.8897° E".
  static String formatCoordinates(double lat, double lng) =>
      '${lat.abs().toStringAsFixed(4)}° ${lat >= 0 ? 'N' : 'S'}, '
      '${lng.abs().toStringAsFixed(4)}° ${lng >= 0 ? 'E' : 'W'}';

  /// "2026-11-24 14:30:15".
  static String formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}
