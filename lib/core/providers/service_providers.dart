import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/services.dart';
import '../models/models.dart';

/// ────────────────────────────────────────────────────────────
/// Service singletons — instantiated once, shared everywhere
/// ────────────────────────────────────────────────────────────

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final promoServiceProvider = Provider<PromoService>((ref) {
  return PromoService();
});

/// ────────────────────────────────────────────────────────────
/// Firebase Auth stream — drives the entire auth state
/// ────────────────────────────────────────────────────────────

final firebaseAuthProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// ────────────────────────────────────────────────────────────
/// Data providers — fetched from Firestore via services
/// ────────────────────────────────────────────────────────────

/// All categories (cached on first load).
final categoriesDataProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.watch(categoryServiceProvider);
  return service.getAll();
});

/// Featured products for home screen.
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.getFeatured();
});

/// Popular products for home screen.
final popularProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.getPopular();
});

/// Offer products for home screen.
final offerProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.getOffers();
});

/// Products by category (parameterised).
final categoryProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, categoryId) async {
  final service = ref.watch(productServiceProvider);
  return service.getByCategory(categoryId);
});

/// Product search results (parameterised).
final productSearchProvider =
    FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final service = ref.watch(productServiceProvider);
  return service.search(query);
});

/// Active promo banners for home carousel.
final promoBannersProvider = FutureProvider<List<PromoBanner>>((ref) async {
  final service = ref.watch(promoServiceProvider);
  return service.getActiveBanners();
});

/// User's order history (real-time stream).
final userOrdersStreamProvider =
    StreamProvider.family<List<AppOrder>, String>((ref, userId) {
  final service = ref.watch(orderServiceProvider);
  return service.watchUserOrders(userId);
});

/// Single order tracking (real-time stream).
final orderTrackingProvider =
    StreamProvider.family<AppOrder?, String>((ref, orderId) {
  final service = ref.watch(orderServiceProvider);
  return service.watchOrder(orderId);
});

/// User's saved addresses (real-time stream).
final userAddressesProvider =
    StreamProvider.family<List<DeliveryAddress>, String>((ref, userId) {
  final service = ref.watch(userServiceProvider);
  return service.watchAddresses(userId);
});

/// User profile (real-time stream).
final userProfileProvider =
    StreamProvider.family<AppUser?, String>((ref, userId) {
  final service = ref.watch(userServiceProvider);
  return service.watchUser(userId);
});
