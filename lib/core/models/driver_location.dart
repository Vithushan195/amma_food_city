import 'package:cloud_firestore/cloud_firestore.dart';

/// Live driver GPS position synced to the order document.
class DriverLocation {
  final double latitude;
  final double longitude;
  final DateTime? updatedAt;

  const DriverLocation({
    required this.latitude,
    required this.longitude,
    this.updatedAt,
  });

  factory DriverLocation.fromMap(Map<String, dynamic> map) {
    DateTime? updatedAt;
    final raw = map['updatedAt'];
    if (raw is Timestamp) updatedAt = raw.toDate();
    if (raw is DateTime) updatedAt = raw;

    return DriverLocation(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      updatedAt: updatedAt,
    );
  }

  int get secondsSinceUpdate {
    if (updatedAt == null) return 999;
    return DateTime.now().difference(updatedAt!).inSeconds;
  }

  bool get isFresh => secondsSinceUpdate < 60;
}
