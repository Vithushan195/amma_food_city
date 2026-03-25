import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Category model for the home grid and categories screen.
class Category {
  final String id;
  final String name;
  final String emoji;
  final Color backgroundColor;
  final IconData? icon;
  final int productCount;
  final String? imageUrl;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    this.backgroundColor = AppColors.accentSubtle,
    this.icon,
    this.productCount = 0,
    this.imageUrl,
  });

  static List<Category> get mockCategories => [
    const Category(
      id: 'vegetables',
      name: 'Vegetables',
      emoji: '🥬',
      backgroundColor: AppColors.chipVegetables,
      productCount: 45,
    ),
    const Category(
      id: 'fruits',
      name: 'Fruits',
      emoji: '🥭',
      backgroundColor: AppColors.chipFruits,
      productCount: 32,
    ),
    const Category(
      id: 'spices',
      name: 'Spices',
      emoji: '🌶️',
      backgroundColor: AppColors.chipSpices,
      productCount: 68,
    ),
    const Category(
      id: 'dairy',
      name: 'Dairy',
      emoji: '🥛',
      backgroundColor: AppColors.chipDairy,
      productCount: 24,
    ),
    const Category(
      id: 'snacks',
      name: 'Snacks',
      emoji: '🍪',
      backgroundColor: AppColors.chipSnacks,
      productCount: 56,
    ),
    const Category(
      id: 'beverages',
      name: 'Beverages',
      emoji: '🧃',
      backgroundColor: AppColors.chipBeverages,
      productCount: 38,
    ),
    const Category(
      id: 'rice-grains',
      name: 'Rice & Grains',
      emoji: '🍚',
      backgroundColor: AppColors.chipFruits,
      productCount: 29,
    ),
    const Category(
      id: 'cooking-oils',
      name: 'Cooking Oils',
      emoji: '🫒',
      backgroundColor: AppColors.chipVegetables,
      productCount: 15,
    ),
    const Category(
      id: 'frozen',
      name: 'Frozen',
      emoji: '🧊',
      backgroundColor: AppColors.chipDairy,
      productCount: 22,
    ),
    const Category(
      id: 'sauces',
      name: 'Sauces',
      emoji: '🫙',
      backgroundColor: AppColors.chipSpices,
      productCount: 31,
    ),
  ];
}
