import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// Firestore service for promo banners and promo code validation.
class PromoService {
  final FirebaseFirestore _db;

  PromoService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // ── Promo Banners ───────────────────────────────────────────

  /// Get active promo banners for the home screen carousel.
  Future<List<PromoBanner>> getActiveBanners() async {
    final snap = await _db
        .collection('promoBanners')
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snap.docs.map(_bannerFromDoc).toList();
  }

  Stream<List<PromoBanner>> watchActiveBanners() {
    return _db
        .collection('promoBanners')
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map(_bannerFromDoc).toList());
  }

  // ── Promo Code Validation ───────────────────────────────────

  /// Validate a promo code and return discount details.
  /// Returns null if code is invalid or expired.
  Future<PromoCodeResult?> validateCode(String code) async {
    final snap = await _db
        .collection('promoCodes')
        .where('code', isEqualTo: code.toUpperCase())
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final d = snap.docs.first.data();

    // Check expiry
    final expiresAt = d['expiresAt'] as Timestamp?;
    if (expiresAt != null && expiresAt.toDate().isBefore(DateTime.now())) {
      return null;
    }

    // Check usage limit
    final usageLimit = d['usageLimit'] as int?;
    final usageCount = d['usageCount'] as int? ?? 0;
    if (usageLimit != null && usageCount >= usageLimit) {
      return null;
    }

    // Check minimum order value
    final minOrder = (d['minOrderValue'] as num?)?.toDouble() ?? 0;

    return PromoCodeResult(
      code: d['code'] ?? code.toUpperCase(),
      discountPercent: (d['discountPercent'] as num?)?.toDouble() ?? 0.10,
      minOrderValue: minOrder,
      maxDiscount: (d['maxDiscount'] as num?)?.toDouble(),
      description: d['description'] ?? '',
    );
  }

  /// Increment usage count after successful order with promo.
  Future<void> incrementUsage(String code) async {
    final snap = await _db
        .collection('promoCodes')
        .where('code', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      await snap.docs.first.reference.update({
        'usageCount': FieldValue.increment(1),
      });
    }
  }

  // ── Mapping ─────────────────────────────────────────────────
  PromoBanner _bannerFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return PromoBanner(
      id: doc.id,
      title: d['title'] ?? '',
      subtitle: d['subtitle'] ?? '',
      ctaText: d['ctaText'],
      backgroundColor: _parseColor(d['backgroundColor']),
      routeTo: d['routeTo'],
    );
  }

  Color _parseColor(dynamic value) {
    if (value is String && value.startsWith('#')) {
      return Color(int.parse(value.replaceFirst('#', '0xFF')));
    }
    return const Color(0xFF0B3B2D);
  }
}

/// Result of promo code validation.
class PromoCodeResult {
  final String code;
  final double discountPercent;
  final double minOrderValue;
  final double? maxDiscount;
  final String description;

  const PromoCodeResult({
    required this.code,
    required this.discountPercent,
    required this.minOrderValue,
    this.maxDiscount,
    required this.description,
  });
}
