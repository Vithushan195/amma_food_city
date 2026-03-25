import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Amma Food City — Typography System
/// Headings: Playfair Display (serif, elegant grocery feel)
/// Body/UI: DM Sans (clean, modern, highly legible)
class AppTypography {
  AppTypography._();

  // ── Font Families ────────────────────────────────────────────────
  static const String fontHeading = 'PlayfairDisplay';
  static const String fontBody = 'DMSans';

  // ── Display / Hero ───────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontHeading,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontHeading,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  // ── Headings ─────────────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: fontHeading,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontHeading,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontBody,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ── Section Headers (on dark green backgrounds) ──────────────────
  static const TextStyle sectionHeaderWhite = TextStyle(
    fontFamily: fontHeading,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.white,
  );

  static const TextStyle sectionSubHeaderWhite = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.accentLight,
  );

  // ── Body Text ────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ── Labels & Buttons ─────────────────────────────────────────────
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.3,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.2,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontBody,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textTertiary,
  );

  // ── Pricing (superscript style) ──────────────────────────────────
  static const TextStyle priceWhole = TextStyle(
    fontFamily: fontBody,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle priceFraction = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle priceCurrency = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle priceStrikethrough = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.0,
    color: AppColors.textTertiary,
    decoration: TextDecoration.lineThrough,
  );

  // ── Category/Tag Chips ───────────────────────────────────────────
  static const TextStyle chipText = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ── Navigation ───────────────────────────────────────────────────
  static const TextStyle navLabel = TextStyle(
    fontFamily: fontBody,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // ── Badge (cart count etc.) ──────────────────────────────────────
  static const TextStyle badge = TextStyle(
    fontFamily: fontBody,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.white,
  );
}
