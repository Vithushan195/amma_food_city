import 'cart_item.dart';
import 'delivery_address.dart';
import 'delivery_info.dart';
import 'driver_info.dart';
import 'driver_location.dart';
import 'order_status.dart';
import 'status_history_entry.dart';

/// Order model — Full Lifecycle Update.
///
/// New fields:
///   - Review: reviewStartedAt, reviewedBy
///   - Revision: revisedItems, revisedSubtotal, revisedTotal,
///               revisionNote, customerConfirmDeadline
///   - Confirmation: confirmedAt, confirmedBy
///   - Cancellation: cancelledAt, cancelledBy, cancelReason
class AppOrder {
  final String id;
  final String userId;
  final List<CartItem> items;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String? promoCode;
  final DeliveryAddress deliveryAddress;
  final String deliverySlot;
  final String paymentMethod;
  final String? paymentIntentId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

  // ── Delivery tracking (Step 7B) ──
  final String? deliveryId;
  final String? statusMessage;
  final DeliveryInfo? deliveryInfo;
  final DriverLocation? driverLocation;
  final List<StatusHistoryEntry> statusHistory;
  final int? estimatedMinutes;
  final DateTime? estimatedDeliveryUpdatedAt;

  // ── Review & Revision (Lifecycle) ──
  final DateTime? reviewStartedAt;
  final String? reviewedBy;
  final List<CartItem>? revisedItems;
  final double? revisedSubtotal;
  final double? revisedTotal;
  final String? revisionNote;
  final DateTime? customerConfirmDeadline;

  // ── Confirmation ──
  final DateTime? confirmedAt;
  final String? confirmedBy; // "customer" | "admin"

  // ── Cancellation ──
  final DateTime? cancelledAt;
  final String? cancelledBy; // "customer" | "admin" | "system"
  final String? cancelReason;

  const AppOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    this.promoCode,
    required this.deliveryAddress,
    required this.deliverySlot,
    required this.paymentMethod,
    this.paymentIntentId,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.deliveryId,
    this.statusMessage,
    this.deliveryInfo,
    this.driverLocation,
    this.statusHistory = const [],
    this.estimatedMinutes,
    this.estimatedDeliveryUpdatedAt,
    this.reviewStartedAt,
    this.reviewedBy,
    this.revisedItems,
    this.revisedSubtotal,
    this.revisedTotal,
    this.revisionNote,
    this.customerConfirmDeadline,
    this.confirmedAt,
    this.confirmedBy,
    this.cancelledAt,
    this.cancelledBy,
    this.cancelReason,
  });

  /// Total item count
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Active delivery phase
  bool get isBeingDelivered => status.isDeliveryPhase;

  /// Live driver location available
  bool get hasLiveDriverLocation =>
      driverLocation != null && driverLocation!.isFresh;

  /// Assigned driver
  DriverInfo? get driver => deliveryInfo?.driver;

  /// Still active
  bool get isActive => status.isActive;

  /// Customer can cancel in-app
  bool get canCancel => status.canCustomerCancel;

  /// Has revised items that differ from original
  bool get hasRevision => revisedItems != null && revisedItems!.isNotEmpty;

  /// The items to display (revised if available and awaiting confirmation)
  List<CartItem> get displayItems =>
      (status == OrderStatus.awaitingConfirmation && revisedItems != null)
          ? revisedItems!
          : items;

  /// The total to display
  double get displayTotal =>
      (status == OrderStatus.awaitingConfirmation && revisedTotal != null)
          ? revisedTotal!
          : total;

  AppOrder copyWith({
    OrderStatus? status,
    String? statusMessage,
    DeliveryInfo? deliveryInfo,
    DriverLocation? driverLocation,
    List<StatusHistoryEntry>? statusHistory,
    int? estimatedMinutes,
    DateTime? deliveredAt,
    List<CartItem>? revisedItems,
    double? revisedTotal,
    String? revisionNote,
  }) {
    return AppOrder(
      id: id,
      userId: userId,
      items: items,
      status: status ?? this.status,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      promoCode: promoCode,
      deliveryAddress: deliveryAddress,
      deliverySlot: deliverySlot,
      paymentMethod: paymentMethod,
      paymentIntentId: paymentIntentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      deliveryId: deliveryId,
      statusMessage: statusMessage ?? this.statusMessage,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      driverLocation: driverLocation ?? this.driverLocation,
      statusHistory: statusHistory ?? this.statusHistory,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      estimatedDeliveryUpdatedAt: estimatedDeliveryUpdatedAt,
      reviewStartedAt: reviewStartedAt,
      reviewedBy: reviewedBy,
      revisedItems: revisedItems ?? this.revisedItems,
      revisedSubtotal: revisedSubtotal,
      revisedTotal: revisedTotal ?? this.revisedTotal,
      revisionNote: revisionNote ?? this.revisionNote,
      customerConfirmDeadline: customerConfirmDeadline,
      confirmedAt: confirmedAt,
      confirmedBy: confirmedBy,
      cancelledAt: cancelledAt,
      cancelledBy: cancelledBy,
      cancelReason: cancelReason,
    );
  }
}
