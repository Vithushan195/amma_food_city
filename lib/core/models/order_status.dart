/// Order status enum — Full Lifecycle Update.
///
/// New statuses: reviewing, awaitingConfirmation
/// Full flow: pending → reviewing → awaitingConfirmation → confirmed →
///            preparing → driverAssigned → driverAtStore →
///            outForDelivery → arriving → delivered
enum OrderStatus {
  pending,
  reviewing, // NEW: Admin checking stock
  awaitingConfirmation, // NEW: Customer must approve revised order
  confirmed,
  preparing,
  dispatched, // Legacy compat — maps to outForDelivery
  driverAssigned,
  driverAtStore,
  outForDelivery,
  arriving,
  delivered,
  cancelled;

  /// Firestore string → enum
  static OrderStatus fromString(String? value) {
    return switch (value?.toString()) {
      'reviewing' => OrderStatus.reviewing,
      'awaiting_confirmation' => OrderStatus.awaitingConfirmation,
      'confirmed' => OrderStatus.confirmed,
      'preparing' => OrderStatus.preparing,
      'dispatched' => OrderStatus.dispatched,
      'driver_assigned' => OrderStatus.driverAssigned,
      'driver_at_store' => OrderStatus.driverAtStore,
      'out_for_delivery' => OrderStatus.outForDelivery,
      'arriving' => OrderStatus.arriving,
      'delivered' => OrderStatus.delivered,
      'cancelled' => OrderStatus.cancelled,
      _ => OrderStatus.pending,
    };
  }

  /// enum → Firestore string
  String toFirestoreString() => switch (this) {
        OrderStatus.pending => 'pending',
        OrderStatus.reviewing => 'reviewing',
        OrderStatus.awaitingConfirmation => 'awaiting_confirmation',
        OrderStatus.confirmed => 'confirmed',
        OrderStatus.preparing => 'preparing',
        OrderStatus.dispatched => 'dispatched',
        OrderStatus.driverAssigned => 'driver_assigned',
        OrderStatus.driverAtStore => 'driver_at_store',
        OrderStatus.outForDelivery => 'out_for_delivery',
        OrderStatus.arriving => 'arriving',
        OrderStatus.delivered => 'delivered',
        OrderStatus.cancelled => 'cancelled',
      };

  /// Human-readable label
  String get label => switch (this) {
        OrderStatus.pending => 'Order Placed',
        OrderStatus.reviewing => 'Under Review',
        OrderStatus.awaitingConfirmation => 'Awaiting Your Confirmation',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.preparing => 'Preparing',
        OrderStatus.dispatched => 'Dispatched',
        OrderStatus.driverAssigned => 'Driver Assigned',
        OrderStatus.driverAtStore => 'Driver at Store',
        OrderStatus.outForDelivery => 'Out for Delivery',
        OrderStatus.arriving => 'Arriving',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
      };

  /// Customer-facing message
  String get customerMessage => switch (this) {
        OrderStatus.pending => 'Your order has been placed',
        OrderStatus.reviewing => 'Store is reviewing your order',
        OrderStatus.awaitingConfirmation => 'Please confirm the updated order',
        OrderStatus.confirmed => 'Your order has been confirmed',
        OrderStatus.preparing => 'Your order is being prepared',
        OrderStatus.dispatched => 'Your order has been dispatched',
        OrderStatus.driverAssigned => 'A driver has been assigned',
        OrderStatus.driverAtStore => 'Your driver has arrived at the store',
        OrderStatus.outForDelivery => 'Your order is on the way!',
        OrderStatus.arriving => 'Your driver is arriving now!',
        OrderStatus.delivered => 'Your order has been delivered',
        OrderStatus.cancelled => 'Your order has been cancelled',
      };

  /// Step index for timeline (0-based). Cancelled = -1.
  int get stepIndex => switch (this) {
        OrderStatus.pending => 0,
        OrderStatus.reviewing => 1,
        OrderStatus.awaitingConfirmation => 2,
        OrderStatus.confirmed => 3,
        OrderStatus.preparing => 4,
        OrderStatus.dispatched => 5,
        OrderStatus.driverAssigned => 5,
        OrderStatus.driverAtStore => 6,
        OrderStatus.outForDelivery => 7,
        OrderStatus.arriving => 8,
        OrderStatus.delivered => 9,
        OrderStatus.cancelled => -1,
      };

  /// Timeline statuses (excludes cancelled and legacy dispatched)
  static List<OrderStatus> get timelineStatuses => [
        OrderStatus.pending,
        OrderStatus.reviewing,
        OrderStatus.awaitingConfirmation,
        OrderStatus.confirmed,
        OrderStatus.preparing,
        OrderStatus.driverAssigned,
        OrderStatus.driverAtStore,
        OrderStatus.outForDelivery,
        OrderStatus.arriving,
        OrderStatus.delivered,
      ];

  /// Active delivery tracking phase
  bool get isDeliveryPhase =>
      this == OrderStatus.driverAssigned ||
      this == OrderStatus.driverAtStore ||
      this == OrderStatus.outForDelivery ||
      this == OrderStatus.arriving;

  /// Whether order is still active
  bool get isActive =>
      this != OrderStatus.delivered && this != OrderStatus.cancelled;

  /// Whether customer can cancel directly in-app
  bool get canCustomerCancel =>
      this == OrderStatus.pending ||
      this == OrderStatus.reviewing ||
      this == OrderStatus.awaitingConfirmation;

  /// Whether customer needs to contact store to cancel
  bool get requiresContactToCancel => isActive && !canCustomerCancel;

  /// Whether this order needs customer action (confirm/decline revision)
  bool get needsCustomerAction => this == OrderStatus.awaitingConfirmation;
}
