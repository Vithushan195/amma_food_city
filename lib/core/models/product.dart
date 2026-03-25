/// Product model for display across the app.
/// Maps directly to Firestore `products` collection.
class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? originalPrice;
  final String? imageUrl;
  final String? weight;
  final String categoryId;
  final String? tag; // "OFFER", "NEW", "BESTSELLER", "DEAL"
  final bool inStock;
  final double? rating;
  final int? reviewCount;

  // ── New fields for Weekly Deals ──────────────────────────────
  final bool isWeeklyDeal;
  final DateTime? dealExpiry;
  final double? dealDiscount; // percentage off, e.g. 30.0 = 30%

  // ── New fields for New Arrivals ──────────────────────────────
  final bool isNewArrival;
  final DateTime? arrivalDate;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    this.weight,
    required this.categoryId,
    this.tag,
    this.inStock = true,
    this.rating,
    this.reviewCount,
    this.isWeeklyDeal = false,
    this.dealExpiry,
    this.dealDiscount,
    this.isNewArrival = false,
    this.arrivalDate,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  /// Whether the weekly deal is still active (not expired).
  bool get isDealActive {
    if (!isWeeklyDeal) return false;
    if (dealExpiry == null) return true; // no expiry set = always active
    return DateTime.now().isBefore(dealExpiry!);
  }

  /// Days since arrival (for "Added Xd ago" label).
  int get daysSinceArrival {
    if (arrivalDate == null) return 0;
    return DateTime.now().difference(arrivalDate!).inDays;
  }

  /// Human-readable "Added Xd ago" string.
  String get arrivalLabel {
    final days = daysSinceArrival;
    if (days == 0) return 'Added today';
    if (days == 1) return 'Added yesterday';
    return 'Added ${days}d ago';
  }

  /// Create a copy with modified fields.
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? imageUrl,
    String? weight,
    String? categoryId,
    String? tag,
    bool? inStock,
    double? rating,
    int? reviewCount,
    bool? isWeeklyDeal,
    DateTime? dealExpiry,
    double? dealDiscount,
    bool? isNewArrival,
    DateTime? arrivalDate,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      weight: weight ?? this.weight,
      categoryId: categoryId ?? this.categoryId,
      tag: tag ?? this.tag,
      inStock: inStock ?? this.inStock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isWeeklyDeal: isWeeklyDeal ?? this.isWeeklyDeal,
      dealExpiry: dealExpiry ?? this.dealExpiry,
      dealDiscount: dealDiscount ?? this.dealDiscount,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      arrivalDate: arrivalDate ?? this.arrivalDate,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Mock Data
  // ═══════════════════════════════════════════════════════════════

  static List<Product> get mockFeatured => [
        const Product(
          id: 'p1',
          name: 'Tilda Basmati Rice',
          price: 8.49,
          originalPrice: 10.99,
          weight: '5 kg',
          categoryId: 'rice-grains',
          tag: 'OFFER',
          rating: 4.8,
          reviewCount: 124,
        ),
        const Product(
          id: 'p2',
          name: 'Alphonso Mango',
          price: 6.99,
          weight: '6 pcs',
          categoryId: 'fruits',
          rating: 4.9,
          reviewCount: 89,
        ),
        const Product(
          id: 'p3',
          name: 'MDH Garam Masala',
          price: 2.49,
          weight: '100g',
          categoryId: 'spices',
          tag: 'BESTSELLER',
          rating: 4.7,
          reviewCount: 201,
        ),
        const Product(
          id: 'p4',
          name: 'Amul Paneer',
          price: 3.29,
          weight: '200g',
          categoryId: 'dairy',
          rating: 4.5,
          reviewCount: 67,
        ),
        const Product(
          id: 'p5',
          name: 'Fresh Curry Leaves',
          price: 0.89,
          weight: '30g',
          categoryId: 'vegetables',
          tag: 'NEW',
          rating: 4.6,
          reviewCount: 43,
        ),
      ];

  static List<Product> get mockPopular => [
        const Product(
          id: 'p6',
          name: 'Aachi Chicken 65 Masala',
          price: 1.49,
          weight: '50g',
          categoryId: 'spices',
          rating: 4.4,
          reviewCount: 156,
        ),
        const Product(
          id: 'p7',
          name: 'Parle-G Biscuits',
          price: 0.99,
          weight: '188g',
          categoryId: 'snacks',
          rating: 4.3,
          reviewCount: 312,
        ),
        const Product(
          id: 'p8',
          name: 'KTC Coconut Oil',
          price: 4.99,
          weight: '500ml',
          categoryId: 'cooking-oils',
          tag: 'OFFER',
          originalPrice: 5.99,
          rating: 4.7,
          reviewCount: 98,
        ),
        const Product(
          id: 'p9',
          name: 'Maggi Noodles',
          price: 3.49,
          originalPrice: 4.29,
          weight: '12 pack',
          categoryId: 'snacks',
          tag: 'OFFER',
          rating: 4.6,
          reviewCount: 445,
        ),
        const Product(
          id: 'p10',
          name: 'Jaffna Curry Powder',
          price: 2.99,
          weight: '200g',
          categoryId: 'spices',
          rating: 4.8,
          reviewCount: 73,
        ),
      ];

  static List<Product> get mockOffers => [
        const Product(
          id: 'p11',
          name: 'Elephant House Cream Soda',
          price: 1.29,
          originalPrice: 1.79,
          weight: '500ml',
          categoryId: 'beverages',
          tag: 'OFFER',
          rating: 4.2,
          reviewCount: 34,
        ),
        const Product(
          id: 'p12',
          name: 'Haldiram Mixture',
          price: 1.99,
          originalPrice: 2.79,
          weight: '200g',
          categoryId: 'snacks',
          tag: 'OFFER',
          rating: 4.5,
          reviewCount: 88,
        ),
        const Product(
          id: 'p13',
          name: 'Lanka Soy Sauce',
          price: 1.59,
          originalPrice: 2.19,
          weight: '350ml',
          categoryId: 'sauces',
          tag: 'OFFER',
          rating: 4.3,
          reviewCount: 52,
        ),
        const Product(
          id: 'p14',
          name: 'Larich Fish Curry Mix',
          price: 2.29,
          originalPrice: 3.49,
          weight: '250g',
          categoryId: 'spices',
          tag: 'OFFER',
          rating: 4.6,
          reviewCount: 61,
        ),
      ];

  // ── Mock Weekly Deals ────────────────────────────────────────
  static List<Product> get mockWeeklyDeals => [
        Product(
          id: 'wd1',
          name: 'Basmati Rice Premium',
          price: 3.49,
          originalPrice: 4.99,
          weight: '500g',
          categoryId: 'rice-grains',
          tag: 'DEAL',
          rating: 4.7,
          reviewCount: 45,
          isWeeklyDeal: true,
          dealExpiry: DateTime.now().add(const Duration(days: 2, hours: 14)),
          dealDiscount: 30,
        ),
        Product(
          id: 'wd2',
          name: 'Coconut Milk Aroy-D',
          price: 1.49,
          originalPrice: 1.99,
          weight: '400ml',
          categoryId: 'cooking-oils',
          tag: 'DEAL',
          rating: 4.5,
          reviewCount: 78,
          isWeeklyDeal: true,
          dealExpiry: DateTime.now().add(const Duration(days: 2, hours: 14)),
          dealDiscount: 25,
        ),
        Product(
          id: 'wd3',
          name: 'Mae Ploy Curry Paste',
          price: 1.79,
          originalPrice: 2.49,
          weight: '250g',
          categoryId: 'sauces',
          tag: 'DEAL',
          rating: 4.6,
          reviewCount: 112,
          isWeeklyDeal: true,
          dealExpiry: DateTime.now().add(const Duration(days: 2, hours: 14)),
          dealDiscount: 28,
        ),
      ];

  // ── Mock New Arrivals ────────────────────────────────────────
  static List<Product> get mockNewArrivals => [
        Product(
          id: 'na1',
          name: 'Jaggery Cubes',
          price: 2.99,
          weight: '250g',
          categoryId: 'spices',
          tag: 'NEW',
          rating: 4.4,
          reviewCount: 12,
          isNewArrival: true,
          arrivalDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Product(
          id: 'na2',
          name: 'Tamarind Paste',
          price: 1.79,
          weight: '500ml',
          categoryId: 'sauces',
          tag: 'NEW',
          rating: 4.3,
          reviewCount: 8,
          isNewArrival: true,
          arrivalDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Product(
          id: 'na3',
          name: 'Moringa Powder',
          price: 3.49,
          weight: '200g',
          categoryId: 'spices',
          tag: 'NEW',
          rating: 4.8,
          reviewCount: 5,
          isNewArrival: true,
          arrivalDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Product(
          id: 'na4',
          name: 'Palmyra Jaggery',
          price: 4.29,
          weight: '300g',
          categoryId: 'snacks',
          tag: 'NEW',
          isNewArrival: true,
          arrivalDate: DateTime.now().subtract(const Duration(days: 8)),
        ),
      ];
}
