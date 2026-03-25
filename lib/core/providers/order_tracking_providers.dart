import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_order.dart';
import '../services/order_service.dart';

// ── NOTE: If you already have orderServiceProvider in service_providers.dart,
// just add the orderStreamProvider there and delete the duplicate below. ──

/// Singleton OrderService provider
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

/// Real-time stream for a single order by ID.
/// Usage: ref.watch(orderStreamProvider(orderId))
final orderStreamProvider =
    StreamProvider.family<AppOrder?, String>((ref, orderId) {
  final service = ref.read(orderServiceProvider);
  return service.watchOrder(orderId);
});
