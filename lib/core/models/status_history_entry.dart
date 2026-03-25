import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_status.dart';

/// A single entry in the order's statusHistory array.
class StatusHistoryEntry {
  final OrderStatus status;
  final String? message;
  final DateTime timestamp;

  const StatusHistoryEntry({
    required this.status,
    this.message,
    required this.timestamp,
  });

  factory StatusHistoryEntry.fromMap(Map<String, dynamic> map) {
    DateTime ts;
    final raw = map['timestamp'];
    if (raw is Timestamp) {
      ts = raw.toDate();
    } else if (raw is DateTime) {
      ts = raw;
    } else {
      ts = DateTime.now();
    }

    return StatusHistoryEntry(
      status: OrderStatus.fromString(map['status'] as String?),
      message: map['message'] as String?,
      timestamp: ts,
    );
  }
}
