import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/category.dart' as models;
import '../models/promo_banner.dart';
import '../config/env_config.dart';
import 'service_providers.dart';

/// Override: set to true to always use Firestore regardless of env.
const bool _forceFirestore = true;

final useFirestoreProvider = Provider<bool>((_) {
  return _forceFirestore || !EnvConfig.enableMockData;
});

// ═══════════════════════════════════════════════════════════════════
// Categories
// ═══════════════════════════════════════════════════════════════════
final categoriesProvider = FutureProvider<List<models.Category>>((ref) async {
  if (ref.watch(useFirestoreProvider)) {
    try {
      final service = ref.watch(categoryServiceProvider);
      final result = await service.getAll();
      if (result.isNotEmpty) return result;
      debugPrint('⚠️ categoriesProvider: Firestore returned empty, using mock');
    } catch (e) {
      debugPrint('❌ categoriesProvider error: $e');
    }
  }
  return models.Category.mockCategories;
});

// ═══════════════════════════════════════════════════════════════════
// Products — Existing
// ═══════════════════════════════════════════════════════════════════
final featuredProductsDataProvider = FutureProvider<List<Product>>((ref) async {
  if (ref.watch(useFirestoreProvider)) {
    try {
      final service = ref.watch(productServiceProvider);
      final result = await service.getFeatured();
      if (result.isNotEmpty) return result;
      debugPrint('⚠️ featuredProducts: Firestore returned empty, using mock');
    } catch (e) {
      debugPrint('❌ featuredProducts error: $e');
    }
  }
  return Product.mockFeatured;
});

final popularProductsDataProvider = FutureProvider<List<Product>>((ref) async {
  if (ref.watch(useFirestoreProvider)) {
    try {
      final service = ref.watch(productServiceProvider);
      final result = await service.getPopular();
      if (result.isNotEmpty) return result;
      debugPrint('⚠️ popularProducts: Firestore returned empty, using mock');
    } catch (e) {
      debugPrint('❌ popularProducts error: $e');
    }
  }
  return Product.mockPopular;
});

final offerProductsDataProvider = FutureProvider<List<Product>>((ref) async {
  if (ref.watch(useFirestoreProvider)) {
    try {
      final service = ref.watch(productServiceProvider);
      final result = await service.getOffers();
      if (result.isNotEmpty) return result;
      debugPrint('⚠️ offerProducts: Firestore returned empty, using mock');
    } catch (e) {
      debugPrint('❌ offerProducts error: $e');
    }
  }
  return Product.mockOffers;
});

// ═══════════════════════════════════════════════════════════════════
// Products — NEW: Weekly Deals & New Arrivals
// ═══════════════════════════════════════════════════════════════════
final weeklyDealsProvider = FutureProvider<List<Product>>((ref) async {
  if (ref.watch(useFirestoreProvider)) {
    try {
      final service = ref.watch(productServiceProvider);
      final result = await service.getWeeklyDeals();
      if (result.isNotEmpty) return result;
      debugPrint('⚠️ weeklyDeals: Firestore returned empty, using mock');
    } catch (e) {
      debugPrint('❌ weeklyDeals error: $e');
    }
  }
  return Product.mockWeeklyDeals;
});

final newArrivalsProvider = FutureProvider<List<Product>>((ref) async {
  if (ref.watch(useFirestoreProvider)) {
    try {
      final service = ref.watch(productServiceProvider);
      final result = await service.getNewArrivals();
      if (result.isNotEmpty) return result;
      debugPrint('⚠️ newArrivals: Firestore returned empty, using mock');
    } catch (e) {
      debugPrint('❌ newArrivals error: $e');
    }
  }
  return Product.mockNewArrivals;
});

// ═══════════════════════════════════════════════════════════════════
// Delivery Slots (reads from storeSettings/delivery)
// ═══════════════════════════════════════════════════════════════════

/// A single delivery time slot.
class DeliverySlot {
  final String label; // e.g. "6–8pm"
  final DateTime start;
  final DateTime end;
  final int capacity;
  final int booked;

  const DeliverySlot({
    required this.label,
    required this.start,
    required this.end,
    this.capacity = 10,
    this.booked = 0,
  });

  bool get isAvailable => booked < capacity;
  int get remaining => capacity - booked;
}

/// Provides the next available delivery slot for the banner.
final nextDeliverySlotProvider = FutureProvider<DeliverySlot?>((ref) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('storeSettings')
        .doc('delivery')
        .get();

    if (!doc.exists || doc.data() == null) {
      debugPrint('⚠️ No storeSettings/delivery doc — using default slot');
      return _defaultSlot();
    }

    final data = doc.data()!;
    final slots = data['slots'] as List<dynamic>?;
    if (slots == null || slots.isEmpty) return _defaultSlot();

    final now = DateTime.now();
    for (final s in slots) {
      final start = (s['start'] as Timestamp).toDate();
      final end = (s['end'] as Timestamp).toDate();
      final capacity = s['capacity'] as int? ?? 10;
      final booked = s['booked'] as int? ?? 0;

      if (end.isAfter(now) && booked < capacity) {
        return DeliverySlot(
          label: s['label'] ?? _formatSlotLabel(start, end),
          start: start,
          end: end,
          capacity: capacity,
          booked: booked,
        );
      }
    }

    return null; // No available slots
  } catch (e) {
    debugPrint('❌ deliverySlot error: $e');
    return _defaultSlot();
  }
});

DeliverySlot _defaultSlot() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day, 18); // 6pm
  final end = DateTime(now.year, now.month, now.day, 20); // 8pm
  // If it's past 8pm, show tomorrow's slot
  if (now.isAfter(end)) {
    final tomorrow = now.add(const Duration(days: 1));
    return DeliverySlot(
      label: 'Tomorrow 6–8pm',
      start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18),
      end: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 20),
    );
  }
  return DeliverySlot(label: 'Today 6–8pm', start: start, end: end);
}

String _formatSlotLabel(DateTime start, DateTime end) {
  final h1 = start.hour > 12 ? start.hour - 12 : start.hour;
  final h2 = end.hour > 12 ? end.hour - 12 : end.hour;
  final p1 = start.hour >= 12 ? 'pm' : 'am';
  final p2 = end.hour >= 12 ? 'pm' : 'am';
  if (p1 == p2) return '$h1–$h2$p2';
  return '$h1$p1–$h2$p2';
}

// ═══════════════════════════════════════════════════════════════════
// Category Products & Search & All Products
// ═══════════════════════════════════════════════════════════════════
final categoryProductsDataProvider =
    FutureProvider.family<List<Product>, String>((ref, categoryId) async {
  if (ref.watch(useFirestoreProvider)) {
    try {
      final service = ref.watch(productServiceProvider);
      final result = await service.getByCategory(categoryId);
      debugPrint(
          '📦 categoryProducts($categoryId): got ${result.length} from Firestore');
      return result;
    } catch (e) {
      debugPrint('❌ categoryProducts($categoryId) error: $e');
    }
  }
  final all = [
    ...Product.mockFeatured,
    ...Product.mockPopular,
    ...Product.mockOffers,
  ];
  return all.where((p) => p.categoryId == categoryId).toList();
});

final productSearchDataProvider =
    FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) return [];
  if (ref.watch(useFirestoreProvider)) {
    try {
      final service = ref.watch(productServiceProvider);
      return service.search(query);
    } catch (e) {
      debugPrint('❌ productSearch error: $e');
    }
  }
  final all = [
    ...Product.mockFeatured,
    ...Product.mockPopular,
    ...Product.mockOffers,
  ];
  final q = query.toLowerCase();
  return all
      .where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.categoryId.toLowerCase().contains(q) ||
          (p.weight?.toLowerCase().contains(q) ?? false))
      .toList();
});

final promoBannersDataProvider = FutureProvider<List<PromoBanner>>((ref) async {
  if (ref.watch(useFirestoreProvider)) {
    try {
      final service = ref.watch(promoServiceProvider);
      final result = await service.getActiveBanners();
      if (result.isNotEmpty) return result;
      debugPrint('⚠️ promoBanners: Firestore returned empty, using mock');
    } catch (e) {
      debugPrint('❌ promoBanners error: $e');
    }
  }
  return PromoBanner.mockBanners;
});

final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  if (ref.watch(useFirestoreProvider)) {
    try {
      final service = ref.watch(productServiceProvider);
      final result = await service.getAll();
      if (result.isNotEmpty) return result;
      debugPrint('⚠️ allProducts: Firestore returned empty, using mock');
    } catch (e) {
      debugPrint('❌ allProducts error: $e');
    }
  }
  return [
    ...Product.mockFeatured,
    ...Product.mockPopular,
    ...Product.mockOffers,
  ];
});
