import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'cart_provider.dart';
import 'auth_provider.dart';

class OrdersState {
  final List<AppOrder> orders;
  final bool isLoading;
  const OrdersState({this.orders = const [], this.isLoading = false});

  List<AppOrder> get activeOrders => orders
      .where((o) =>
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled)
      .toList();
  List<AppOrder> get completedOrders => orders
      .where((o) =>
          o.status == OrderStatus.delivered ||
          o.status == OrderStatus.cancelled)
      .toList();

  OrdersState copyWith({List<AppOrder>? orders, bool? isLoading}) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  OrdersNotifier(this._ref) : super(const OrdersState());

  Future<AppOrder> placeOrder({
    required DeliveryAddress address,
    required String deliverySlot,
    required String paymentMethod,
    double discount = 0,
    String? promoCode,
  }) async {
    final cart = _ref.read(cartProvider);
    final auth = _ref.read(authProvider);
    final items = cart.itemList;
    final subtotal = cart.subtotal;
    final deliveryFee = cart.deliveryFee;
    final total = subtotal - discount + deliveryFee;
    final userId = auth.user?.uid ?? 'guest';

    // Create Firestore document
    final docRef = _db.collection('orders').doc();
    final orderData = {
      'userId': userId,
      'items': items
          .map((item) => {
                'productId': item.product.id,
                'productName': item.product.name,
                'price': item.product.price,
                'quantity': item.quantity,
                'subtotal': item.subtotal,
              })
          .toList(),
      'status': 'pending',
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'promoCode': promoCode,
      'deliveryAddress': {
        'label': address.label,
        'line1': address.line1,
        'line2': address.line2,
        'city': address.city,
        'postcode': address.postcode,
      },
      'deliverySlot': deliverySlot,
      'paymentMethod': paymentMethod,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(orderData);

    final order = AppOrder(
      id: docRef.id,
      userId: userId,
      items: items,
      status: OrderStatus.pending,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      promoCode: promoCode,
      deliveryAddress: address,
      deliverySlot: deliverySlot,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );

    final updated = [order, ...state.orders];
    state = state.copyWith(orders: updated);

    // Clear cart
    _ref.read(cartProvider.notifier).clear();
    return order;
  }

  void cancelOrder(String orderId) async {
    // Update Firestore
    await _db.collection('orders').doc(orderId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updated = state.orders.map((o) {
      if (o.id == orderId &&
          (o.status == OrderStatus.pending ||
              o.status == OrderStatus.confirmed)) {
        return AppOrder(
          id: o.id,
          userId: o.userId,
          items: o.items,
          status: OrderStatus.cancelled,
          subtotal: o.subtotal,
          deliveryFee: o.deliveryFee,
          discount: o.discount,
          total: o.total,
          promoCode: o.promoCode,
          deliveryAddress: o.deliveryAddress,
          deliverySlot: o.deliverySlot,
          paymentMethod: o.paymentMethod,
          createdAt: o.createdAt,
        );
      }
      return o;
    }).toList();
    state = state.copyWith(orders: updated);
  }

  void reorder(AppOrder order) {
    _ref.read(cartProvider.notifier).addItems(order.items);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    final auth = _ref.read(authProvider);
    if (auth.user == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final snapshot = await _db
        .collection('orders')
        .where('userId', isEqualTo: auth.user!.uid)
        .orderBy('createdAt', descending: true)
        .get();

    // For now, just update loading state
    // Full deserialization can be added later
    state = state.copyWith(isLoading: false);
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(ref);
});
