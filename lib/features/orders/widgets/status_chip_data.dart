import 'package:flutter/material.dart';
import '../../../core/models/order_status.dart';
import '../../../core/theme/app_colors.dart';

/// Centralized status chip colors and labels for both
/// orders_screen.dart and order_detail_screen.dart.
/// Avoids non-exhaustive switch errors in multiple files.
class StatusChipData {
  static (Color, Color) colors(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => (const Color(0xFF856404), const Color(0xFFFFF3CD)),
      OrderStatus.reviewing => (
          const Color(0xFF991B1B),
          const Color(0xFFFEE2E2)
        ),
      OrderStatus.awaitingConfirmation => (
          const Color(0xFF9A3412),
          const Color(0xFFFFF7ED)
        ),
      OrderStatus.confirmed => (AppColors.primary, AppColors.accentSubtle),
      OrderStatus.preparing => (
          const Color(0xFF0C5460),
          const Color(0xFFD1ECF1)
        ),
      OrderStatus.dispatched => (
          const Color(0xFF1A5276),
          const Color(0xFFD6E9F8)
        ),
      OrderStatus.driverAssigned => (
          const Color(0xFF1A5276),
          const Color(0xFFD6E9F8)
        ),
      OrderStatus.driverAtStore => (
          const Color(0xFF0C5460),
          const Color(0xFFD1ECF1)
        ),
      OrderStatus.outForDelivery => (
          const Color(0xFF1A5276),
          const Color(0xFFD6E9F8)
        ),
      OrderStatus.arriving => (
          const Color(0xFF6B21A8),
          const Color(0xFFE9D5FF)
        ),
      OrderStatus.delivered => (
          const Color(0xFF155724),
          const Color(0xFFD4EDDA)
        ),
      OrderStatus.cancelled => (
          const Color(0xFF721C24),
          const Color(0xFFF8D7DA)
        ),
    };
  }

  static String label(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => 'Pending',
      OrderStatus.reviewing => 'Under Review',
      OrderStatus.awaitingConfirmation => 'Needs Confirmation',
      OrderStatus.confirmed => 'Confirmed',
      OrderStatus.preparing => 'Preparing',
      OrderStatus.dispatched => 'On the way',
      OrderStatus.driverAssigned => 'Driver assigned',
      OrderStatus.driverAtStore => 'At store',
      OrderStatus.outForDelivery => 'On the way',
      OrderStatus.arriving => 'Arriving',
      OrderStatus.delivered => 'Delivered',
      OrderStatus.cancelled => 'Cancelled',
    };
  }
}
