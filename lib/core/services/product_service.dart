import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Firestore service for the products collection.
/// Fetches all products once, caches in memory, filters client-side.
/// For stores with <500 products this is efficient and avoids index issues.
class ProductService {
  final FirebaseFirestore _db;
  List<Product>? _cachedAll;

  ProductService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('products');

  // ── Fetch ALL products (simple query, no composite index) ───
  Future<List<Product>> getAll({bool forceRefresh = false}) async {
    if (_cachedAll != null && !forceRefresh) return _cachedAll!;
    try {
      final snap = await _collection.get();
      _cachedAll = snap.docs.map(_fromDoc).toList();
      debugPrint(
          'ProductService: fetched ${_cachedAll!.length} products from Firestore');
      return _cachedAll!;
    } catch (e) {
      debugPrint('ProductService.getAll error: $e');
      rethrow;
    }
  }

  void clearCache() => _cachedAll = null;

  // ── Single Product ───────────────────────────────────────────
  Future<Product?> getProduct(String id) async {
    if (_cachedAll != null) {
      final cached = _cachedAll!.where((p) => p.id == id);
      if (cached.isNotEmpty) return cached.first;
    }
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  // ── Featured Products ────────────────────────────────────────
  Future<List<Product>> getFeatured({int limit = 10}) async {
    final all = await getAll();
    final featured = all
        .where((p) =>
            p.inStock &&
            (p.tag == 'OFFER' || p.tag == 'BESTSELLER' || p.tag == 'NEW'))
        .toList()
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return featured.take(limit).toList();
  }

  // ── Popular Products ─────────────────────────────────────────
  Future<List<Product>> getPopular({int limit = 10}) async {
    final all = await getAll();
    final popular = all.where((p) => p.inStock).toList()
      ..sort((a, b) => (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0));
    return popular.take(limit).toList();
  }

  // ── Special Offers ───────────────────────────────────────────
  Future<List<Product>> getOffers({int limit = 10}) async {
    final all = await getAll();
    final offers = all.where((p) => p.inStock && p.tag == 'OFFER').toList()
      ..sort((a, b) => a.price.compareTo(b.price));
    return offers.take(limit).toList();
  }

  // ── Weekly Deals (NEW) ───────────────────────────────────────
  /// Returns products where isWeeklyDeal == true and dealExpiry is in the future.
  Future<List<Product>> getWeeklyDeals({int limit = 10}) async {
    final all = await getAll();
    final now = DateTime.now();
    final deals = all
        .where((p) =>
            p.inStock &&
            p.isWeeklyDeal &&
            (p.dealExpiry == null || p.dealExpiry!.isAfter(now)))
        .toList()
      ..sort((a, b) => (b.dealDiscount ?? 0).compareTo(a.dealDiscount ?? 0));
    return deals.take(limit).toList();
  }

  // ── New Arrivals (NEW) ───────────────────────────────────────
  /// Returns products where isNewArrival == true, sorted by arrivalDate desc.
  Future<List<Product>> getNewArrivals({int limit = 10}) async {
    final all = await getAll();
    final arrivals = all.where((p) => p.inStock && p.isNewArrival).toList()
      ..sort((a, b) => (b.arrivalDate ?? DateTime(2000))
          .compareTo(a.arrivalDate ?? DateTime(2000)));
    return arrivals.take(limit).toList();
  }

  // ── Products by Category ─────────────────────────────────────
  Future<List<Product>> getByCategory(
    String categoryId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
    String sortBy = 'reviewCount',
    bool descending = true,
  }) async {
    final all = await getAll();
    var filtered =
        all.where((p) => p.categoryId == categoryId && p.inStock).toList();
    filtered.sort((a, b) {
      final cmp = switch (sortBy) {
        'price' => a.price.compareTo(b.price),
        'name' => a.name.compareTo(b.name),
        'rating' => (a.rating ?? 0).compareTo(b.rating ?? 0),
        _ => (a.reviewCount ?? 0).compareTo(b.reviewCount ?? 0),
      };
      return descending ? -cmp : cmp;
    });
    return filtered.take(limit).toList();
  }

  // ── Search ───────────────────────────────────────────────────
  Future<List<Product>> search(String query, {int limit = 20}) async {
    if (query.isEmpty) return [];
    final all = await getAll();
    final q = query.toLowerCase();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.categoryId.toLowerCase().contains(q) ||
            (p.weight?.toLowerCase().contains(q) ?? false) ||
            (p.description?.toLowerCase().contains(q) ?? false))
        .take(limit)
        .toList();
  }

  /// Convert Product → Firestore map (used by seed script).
  static Map<String, dynamic> toMap(Product p) {
    return {
      'name': p.name,
      'description': p.description,
      'price': p.price,
      'originalPrice': p.originalPrice,
      'imageUrl': p.imageUrl,
      'weight': p.weight,
      'categoryId': p.categoryId,
      'tag': p.tag,
      'inStock': p.inStock,
      'rating': p.rating,
      'reviewCount': p.reviewCount,
      'isWeeklyDeal': p.isWeeklyDeal,
      'dealExpiry': p.dealExpiry,
      'dealDiscount': p.dealDiscount,
      'isNewArrival': p.isNewArrival,
      'arrivalDate': p.arrivalDate,
    };
  }

  // ── Firestore Document → Product ─────────────────────────────
  Product _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Product(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'],
      price: (d['price'] as num?)?.toDouble() ?? 0,
      originalPrice: d['originalPrice'] != null
          ? (d['originalPrice'] as num).toDouble()
          : null,
      imageUrl: d['imageUrl'],
      weight: d['weight'],
      categoryId: d['categoryId'] ?? '',
      tag: d['tag'],
      inStock: d['inStock'] ?? true,
      rating: d['rating'] != null ? (d['rating'] as num).toDouble() : null,
      reviewCount: d['reviewCount'] as int?,
      // New fields — safe parsing with defaults
      isWeeklyDeal: d['isWeeklyDeal'] ?? false,
      dealExpiry: d['dealExpiry'] != null
          ? (d['dealExpiry'] as Timestamp).toDate()
          : null,
      dealDiscount: d['dealDiscount'] != null
          ? (d['dealDiscount'] as num).toDouble()
          : null,
      isNewArrival: d['isNewArrival'] ?? false,
      arrivalDate: d['arrivalDate'] != null
          ? (d['arrivalDate'] as Timestamp).toDate()
          : null,
    );
  }
}
