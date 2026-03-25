import 'package:cloud_firestore/cloud_firestore.dart';
import 'driver_info.dart';

/// Full delivery metadata synced by DeliveryWatcher (Step 7A).
class DeliveryInfo {
  final String deliveryId;
  final String status;
  final String type;
  final DriverInfo? driver;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final int? estimatedMinutes;
  final String? trackingUrl;

  const DeliveryInfo({
    required this.deliveryId,
    required this.status,
    required this.type,
    this.driver,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.estimatedMinutes,
    this.trackingUrl,
  });

  factory DeliveryInfo.fromMap(Map<String, dynamic> map) {
    return DeliveryInfo(
      deliveryId: map['deliveryId'] as String? ?? '',
      status: map['status'] as String? ?? '',
      type: map['type'] as String? ?? 'own_driver',
      driver: map['driver'] != null
          ? DriverInfo.fromMap(Map<String, dynamic>.from(map['driver']))
          : null,
      assignedAt: _toDateTime(map['assignedAt']),
      pickedUpAt: _toDateTime(map['pickedUpAt']),
      deliveredAt: _toDateTime(map['deliveredAt']),
      estimatedMinutes: (map['estimatedMinutes'] as num?)?.toInt(),
      trackingUrl: map['trackingUrl'] as String?,
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
