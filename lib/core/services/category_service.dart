import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

/// Firestore service for the categories collection.
class CategoryService {
  final FirebaseFirestore _db;

  CategoryService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('categories');

  /// Get all categories, ordered by sortOrder.
  Future<List<Category>> getAll() async {
    final snap = await _collection.orderBy('sortOrder').get();
    return snap.docs.map(_fromDoc).toList();
  }

  /// Real-time stream of all categories.
  Stream<List<Category>> watchAll() {
    return _collection.orderBy('sortOrder').snapshots().map(
      (snap) => snap.docs.map(_fromDoc).toList(),
    );
  }

  /// Get a single category by ID.
  Future<Category?> getCategory(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  // ── Mapping ─────────────────────────────────────────────────
  Category _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Category(
      id: doc.id,
      name: d['name'] ?? '',
      emoji: d['emoji'] ?? '📦',
      backgroundColor: _parseColor(d['backgroundColor']),
      productCount: d['productCount'] ?? 0,
      imageUrl: d['imageUrl'],
    );
  }

  Color _parseColor(dynamic value) {
    if (value == null) return AppColors.accentSubtle;
    if (value is String && value.startsWith('#')) {
      return Color(int.parse(value.replaceFirst('#', '0xFF')));
    }
    if (value is int) return Color(value);
    return AppColors.accentSubtle;
  }

  /// Convert Category to Firestore map (for seeding).
  static Map<String, dynamic> toMap(Category c, int sortOrder) {
    return {
      'name': c.name,
      'emoji': c.emoji,
      'backgroundColor': '#${c.backgroundColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
      'productCount': c.productCount,
      'imageUrl': c.imageUrl,
      'sortOrder': sortOrder,
    };
  }
}
