/// Firestore Seed Script
/// Run once to populate initial data into Firestore.
///
/// Usage:
///   1. Ensure Firebase is initialised in your app
///   2. Call FirestoreSeed.seedAll() from a dev screen or CLI tool
///   3. Comment out after seeding to avoid duplicates
///
/// Alternatively, use the Firebase CLI:
///   firebase emulators:start --import=./seed-data
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';

class FirestoreSeed {
  static final _db = FirebaseFirestore.instance;

  /// Seed all collections. Safe to run multiple times (uses set with merge).
  static Future<void> seedAll() async {
    await seedCategories();
    await seedProducts();
    await seedPromoBanners();
    await seedPromoCodes();
  }

  // ── Categories ──────────────────────────────────────────────
  static Future<void> seedCategories() async {
    final categories = Category.mockCategories;
    final batch = _db.batch();

    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      batch.set(
        _db.collection('categories').doc(cat.id),
        CategoryService.toMap(cat, i),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
    // ignore: avoid_print
    print('Seeded ${categories.length} categories');
  }

  // ── Products ────────────────────────────────────────────────
  static Future<void> seedProducts() async {
    final allProducts = [
      ...Product.mockFeatured,
      ...Product.mockPopular,
      ...Product.mockOffers,
    ];

    // Deduplicate by ID
    final seen = <String>{};
    final unique = allProducts.where((p) => seen.add(p.id)).toList();

    final batch = _db.batch();
    for (final product in unique) {
      batch.set(
        _db.collection('products').doc(product.id),
        ProductService.toMap(product),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
    // ignore: avoid_print
    print('Seeded ${unique.length} products');
  }

  // ── Promo Banners ───────────────────────────────────────────
  static Future<void> seedPromoBanners() async {
    final banners = PromoBanner.mockBanners;
    final batch = _db.batch();

    for (int i = 0; i < banners.length; i++) {
      final b = banners[i];
      batch.set(
        _db.collection('promoBanners').doc('banner_${i + 1}'),
        {
          'title': b.title,
          'subtitle': b.subtitle,
          'ctaText': b.ctaText,
          'backgroundColor':
              '#${b.backgroundColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
          'routeTo': b.routeTo,
          'isActive': true,
          'sortOrder': i,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
    // ignore: avoid_print
    print('Seeded ${banners.length} promo banners');
  }

  // ── Promo Codes ─────────────────────────────────────────────
  static Future<void> seedPromoCodes() async {
    final codes = [
      {
        'code': 'AMMA10',
        'discountPercent': 0.10,
        'description': '10% off your order',
        'minOrderValue': 10.0,
        'maxDiscount': 15.0,
        'usageLimit': 1000,
        'usageCount': 0,
        'isActive': true,
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 90)),
        ),
      },
      {
        'code': 'WELCOME',
        'discountPercent': 0.10,
        'description': '10% off your first order',
        'minOrderValue': 5.0,
        'maxDiscount': 10.0,
        'usageLimit': 500,
        'usageCount': 0,
        'isActive': true,
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 180)),
        ),
      },
      {
        'code': 'AMMA20',
        'discountPercent': 0.20,
        'description': '20% off orders over £30',
        'minOrderValue': 30.0,
        'maxDiscount': 20.0,
        'usageLimit': 200,
        'usageCount': 0,
        'isActive': true,
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 30)),
        ),
      },
    ];

    final batch = _db.batch();
    for (final code in codes) {
      batch.set(
        _db.collection('promoCodes').doc(code['code'] as String),
        code,
        SetOptions(merge: true),
      );
    }

    await batch.commit();
    // ignore: avoid_print
    print('Seeded ${codes.length} promo codes');
  }
}
