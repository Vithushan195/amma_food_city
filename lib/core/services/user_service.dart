import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Firestore service for user profiles and saved addresses.
/// Path: users/{uid} and users/{uid}/addresses/{addrId}
class UserService {
  final FirebaseFirestore _db;

  UserService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _addressesCol(String uid) =>
      _userDoc(uid).collection('addresses');

  // ── User Profile ────────────────────────────────────────────

  /// Create user document on first sign-up.
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    String? phone,
  }) async {
    await _userDoc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'defaultAddressId': null,
      'fcmToken': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get user profile.
  Future<AppUser?> getUser(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    return _userFromDoc(uid, doc.data()!);
  }

  /// Watch user profile changes.
  Stream<AppUser?> watchUser(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _userFromDoc(uid, doc.data()!);
    });
  }

  /// Update user profile fields.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _userDoc(uid).update(data);
  }

  /// Store FCM token for push notifications.
  Future<void> updateFcmToken(String uid, String token) async {
    await _userDoc(uid).update({'fcmToken': token});
  }

  // ── Addresses ───────────────────────────────────────────────

  /// Get all saved addresses for a user.
  Future<List<DeliveryAddress>> getAddresses(String uid) async {
    final snap = await _addressesCol(uid).orderBy('isDefault', descending: true).get();
    return snap.docs.map(_addressFromDoc).toList();
  }

  /// Watch addresses (real-time).
  Stream<List<DeliveryAddress>> watchAddresses(String uid) {
    return _addressesCol(uid)
        .orderBy('isDefault', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_addressFromDoc).toList());
  }

  /// Add a new address (max 5 per user).
  Future<String> addAddress(String uid, DeliveryAddress address) async {
    // Check limit
    final existing = await _addressesCol(uid).get();
    if (existing.size >= 5) {
      throw Exception('Maximum 5 addresses allowed');
    }

    // If this is the first address or marked as default, unset others
    if (address.isDefault || existing.size == 0) {
      await _clearDefaultAddresses(uid);
    }

    final doc = await _addressesCol(uid).add({
      'label': address.label,
      'line1': address.line1,
      'line2': address.line2,
      'city': address.city,
      'postcode': address.postcode,
      'isDefault': address.isDefault || existing.size == 0,
    });

    // Update user's default address ID
    if (address.isDefault || existing.size == 0) {
      await _userDoc(uid).update({'defaultAddressId': doc.id});
    }

    return doc.id;
  }

  /// Update an existing address.
  Future<void> updateAddress(
    String uid,
    String addressId,
    DeliveryAddress address,
  ) async {
    if (address.isDefault) {
      await _clearDefaultAddresses(uid);
      await _userDoc(uid).update({'defaultAddressId': addressId});
    }

    await _addressesCol(uid).doc(addressId).update({
      'label': address.label,
      'line1': address.line1,
      'line2': address.line2,
      'city': address.city,
      'postcode': address.postcode,
      'isDefault': address.isDefault,
    });
  }

  /// Delete an address.
  Future<void> deleteAddress(String uid, String addressId) async {
    await _addressesCol(uid).doc(addressId).delete();
  }

  /// Set an address as default.
  Future<void> setDefaultAddress(String uid, String addressId) async {
    await _clearDefaultAddresses(uid);
    await _addressesCol(uid).doc(addressId).update({'isDefault': true});
    await _userDoc(uid).update({'defaultAddressId': addressId});
  }

  Future<void> _clearDefaultAddresses(String uid) async {
    final defaults = await _addressesCol(uid)
        .where('isDefault', isEqualTo: true)
        .get();
    final batch = _db.batch();
    for (final doc in defaults.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }

  // ── Mapping ─────────────────────────────────────────────────
  AppUser _userFromDoc(String uid, Map<String, dynamic> d) {
    return AppUser(
      uid: uid,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'],
      avatarUrl: d['avatarUrl'],
      defaultAddressId: d['defaultAddressId'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  DeliveryAddress _addressFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return DeliveryAddress(
      id: doc.id,
      label: d['label'] ?? '',
      line1: d['line1'] ?? '',
      line2: d['line2'],
      city: d['city'] ?? '',
      postcode: d['postcode'] ?? '',
      isDefault: d['isDefault'] ?? false,
    );
  }
}
