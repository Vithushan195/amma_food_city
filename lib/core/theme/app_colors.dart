import 'package:flutter/material.dart';

/// Amma Food City — Design System Colors
/// Gromuse-inspired palette: dark green foundations, lime accents
class AppColors {
  AppColors._();

  // ── Primary: Dark Green ──────────────────────────────────────────
  static const Color primary = Color(0xFF0B3B2D);
  static const Color primaryLight = Color(0xFF145A44);
  static const Color primaryDark = Color(0xFF072A1F);
  static const Color primarySurface = Color(0xFF0E4D3A);

  // ── Accent: Lime Green ───────────────────────────────────────────
  static const Color accent = Color(0xFFA8E06C);
  static const Color accentDark = Color(0xFF8BC554);
  static const Color accentLight = Color(0xFFC5EE9A);
  static const Color accentSubtle = Color(0xFFEAF7D8);

  // ── Neutrals ─────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color backgroundGrey = Color(0xFFF2F3F5);
  static const Color cardGrey = Color(0xFFE8EAED);
  static const Color divider = Color(0xFFDDE0E4);
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF1A1D21);

  // ── Semantic ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Category Tag Chips (pastel backgrounds) ──────────────────────
  static const Color chipVegetables = Color(0xFFD4EDDA);
  static const Color chipFruits = Color(0xFFFFF3CD);
  static const Color chipDairy = Color(0xFFD1ECF1);
  static const Color chipSpices = Color(0xFFF8D7DA);
  static const Color chipSnacks = Color(0xFFE2D9F3);
  static const Color chipBeverages = Color(0xFFD6E9F8);

  // ── Gradients ────────────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  // ── Shadows ──────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get bottomNavShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];
}
