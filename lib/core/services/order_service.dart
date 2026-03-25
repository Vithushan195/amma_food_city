import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_order.dart';
import '../models/cart_item.dart';
import '../models/delivery_address.dart';
import '../models/delivery_info.dart';
import '../models/driver_location.dart';
import '../models/order_status.dart';
import '../models/product.dart';
import '../models/status_history_entry.dart';

/// Firestore orders service — Full Lifecycle Update.
///
/// New methods: cancelOrder, confirmRevision, declineRevision
/// Updated _fromDoc: parses revision, review, cancel fields
class OrderService {
  final FirebaseFirestore _firestore;
  late final CollectionReference _collection;

  OrderService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection('orders');
  }

  // ══════════════════════════════════════════════════════
  // CREATE
  // ══════════════════════════════════════════════════════

  Future<String> createOrder({
    required String userId,
    required List<CartItem> items,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required double total,
    String? promoCode,
    required DeliveryAddress deliveryAddress,
    required String deliverySlot,
    required String paymentMethod,
    String? paymentIntentId,
  }) async {
    final doc = _collection.doc();
    final data = {
      'userId': userId,
      'items': items.map(_cartItemToMap).toList(),
      'status': 'pending',
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'promoCode': promoCode,
      'addressSnapshot': {
        'label': deliveryAddress.label,
        'line1': deliveryAddress.line1,
        'line2': deliveryAddress.line2,
        'city': deliveryAddress.city,
        'postcode': deliveryAddress.postcode,
      },
      'deliverySlot': deliverySlot,
      'paymentMethod': paymentMethod,
      'paymentIntentId': paymentIntentId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await doc.set(data);
    return doc.id;
  }

  // ══════════════════════════════════════════════════════
  // READ
  // ══════════════════════════════════════════════════════

  Future<AppOrder?> getOrder(String orderId) async {
    final doc = await _collection.doc(orderId).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  Stream<AppOrder?> watchOrder(String orderId) {
    return _collection.doc(orderId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _fromDoc(doc);
    });
  }

  Future<List<AppOrder>> getUserOrders(String userId) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  Stream<List<AppOrder>> watchUserOrders(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  // ══════════════════════════════════════════════════════
  // CUSTOMER ACTIONS (Lifecycle)
  // ══════════════════════════════════════════════════════

  /// Customer cancels order (only allowed before confirmed)
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    await _collection.doc(orderId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancelledBy': 'customer',
      'cancelReason': reason ?? 'Customer cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Customer confirms the revised order
  Future<void> confirmRevision(String orderId) async {
    // Get current order to copy revised items → items
    final doc = await _collection.doc(orderId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;

    final updateData = <String, dynamic>{
      'status': 'confirmed',
      'confirmedAt': FieldValue.serverTimestamp(),
      'confirmedBy': 'customer',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // If there were revisions, replace items with revised items
    if (data['revisedItems'] != null) {
      updateData['items'] = data['revisedItems'];
      updateData['subtotal'] = data['revisedSubtotal'] ?? data['subtotal'];
      updateData['total'] = data['revisedTotal'] ?? data['total'];
    }

    await _collection.doc(orderId).update(updateData);
  }

  /// Customer declines the revised order (= cancel)
  Future<void> declineRevision(String orderId) async {
    await _collection.doc(orderId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancelledBy': 'customer',
      'cancelReason': 'Customer declined revised order',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ══════════════════════════════════════════════════════
  // CartItem Serialization
  // ══════════════════════════════════════════════════════

  Map<String, dynamic> _cartItemToMap(CartItem item) {
    return {
      'productId': item.product.id,
      'name': item.product.name,
      'price': item.product.price,
      'imageUrl': item.product.imageUrl,
      'weight': item.product.weight,
      'quantity': item.quantity,
      'selectedWeight': item.selectedWeight,
    };
  }

  CartItem _cartItemFromMap(Map<String, dynamic> m) {
    final product = Product(
      id: m['productId'] as String? ?? '',
      name: m['name'] as String? ?? '',
      price: (m['price'] as num?)?.toDouble() ?? 0,
      imageUrl: m['imageUrl'] as String?,
      weight: m['weight'] as String?,
      categoryId: '',
    );
    return CartItem(
      product: product,
      quantity: (m['quantity'] as num?)?.toInt() ?? 1,
      selectedWeight: m['selectedWeight'] as String?,
    );
  }

  // ══════════════════════════════════════════════════════
  // _fromDoc (Full Lifecycle)
  // ══════════════════════════════════════════════════════

  AppOrder _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // ── Items ──
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((e) => _cartItemFromMap(Map<String, dynamic>.from(e)))
        .toList();

    // ── Revised Items ──
    List<CartItem>? revisedItems;
    final rawRevised = data['revisedItems'] as List<dynamic>?;
    if (rawRevised != null) {
      revisedItems = rawRevised
          .map((e) => _cartItemFromMap(Map<String, dynamic>.from(e)))
          .toList();
    }

    // ── Address ──
    final addrRaw = data['addressSnapshot'] ?? data['deliveryAddress'];
    DeliveryAddress address;
    if (addrRaw != null && addrRaw is Map) {
      final a = Map<String, dynamic>.from(addrRaw);
      address = DeliveryAddress(
        id: doc.id,
        label: a['label'] as String? ?? 'Home',
        line1: a['line1'] as String? ?? '',
        line2: a['line2'] as String?,
        city: a['city'] as String? ?? '',
        postcode: a['postcode'] as String? ?? '',
      );
    } else {
      address = DeliveryAddress(
          id: doc.id, label: 'Home', line1: '', city: '', postcode: '');
    }

    // ── Timestamps ──
    final createdAt = _toDateTime(data['createdAt']) ?? DateTime.now();
    final updatedAt = _toDateTime(data['updatedAt']);
    final deliveredAt = _toDateTime(data['deliveredAt']);

    // ── Delivery (Step 7B) ──
    DeliveryInfo? deliveryInfo;
    if (data['deliveryInfo'] != null) {
      deliveryInfo =
          DeliveryInfo.fromMap(Map<String, dynamic>.from(data['deliveryInfo']));
    }

    DriverLocation? driverLocation;
    if (data['driverLocation'] != null) {
      driverLocation = DriverLocation.fromMap(
          Map<String, dynamic>.from(data['driverLocation']));
    }

    final statusHistory = (data['statusHistory'] as List<dynamic>?)
            ?.map(
                (e) => StatusHistoryEntry.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    int? estimatedMinutes;
    DateTime? estimatedDeliveryUpdatedAt;
    if (data['estimatedDelivery'] != null) {
      final ed = Map<String, dynamic>.from(data['estimatedDelivery']);
      estimatedMinutes = (ed['minutes'] as num?)?.toInt();
      estimatedDeliveryUpdatedAt = _toDateTime(ed['updatedAt']);
    }

    return AppOrder(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      items: itemsList,
      status: OrderStatus.fromString(data['status'] as String?),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      promoCode: data['promoCode'] as String?,
      deliveryAddress: address,
      deliverySlot: data['deliverySlot'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? '',
      paymentIntentId: data['paymentIntentId'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deliveredAt: deliveredAt,
      // Delivery
      deliveryId: data['deliveryId'] as String?,
      statusMessage: data['statusMessage'] as String?,
      deliveryInfo: deliveryInfo,
      driverLocation: driverLocation,
      statusHistory: statusHistory,
      estimatedMinutes: estimatedMinutes,
      estimatedDeliveryUpdatedAt: estimatedDeliveryUpdatedAt,
      // Review & Revision
      reviewStartedAt: _toDateTime(data['reviewStartedAt']),
      reviewedBy: data['reviewedBy'] as String?,
      revisedItems: revisedItems,
      revisedSubtotal: (data['revisedSubtotal'] as num?)?.toDouble(),
      revisedTotal: (data['revisedTotal'] as num?)?.toDouble(),
      revisionNote: data['revisionNote'] as String?,
      customerConfirmDeadline: _toDateTime(data['customerConfirmDeadline']),
      // Confirmation
      confirmedAt: _toDateTime(data['confirmedAt']),
      confirmedBy: data['confirmedBy'] as String?,
      // Cancellation
      cancelledAt: _toDateTime(data['cancelledAt']),
      cancelledBy: data['cancelledBy'] as String?,
      cancelReason: data['cancelReason'] as String?,
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
