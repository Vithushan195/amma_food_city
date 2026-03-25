import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Superscript-style price display: £3.⁴⁹
/// The pence portion is rendered smaller and raised, Gromuse-style.
///
/// ```dart
/// SuperscriptPrice(price: 3.49)
/// SuperscriptPrice(price: 3.49, originalPrice: 4.99) // with strikethrough
/// SuperscriptPrice(price: 3.49, size: PriceSize.small)
/// ```
enum PriceSize { small, medium, large }

class SuperscriptPrice extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final PriceSize size;
  final Color? color;
  final String currency;

  const SuperscriptPrice({
    super.key,
    required this.price,
    this.originalPrice,
    this.size = PriceSize.medium,
    this.color,
    this.currency = '£',
  });

  double get _wholeSize => switch (size) {
        PriceSize.small => 16,
        PriceSize.medium => 20,
        PriceSize.large => 28,
      };

  double get _fractionSize => switch (size) {
        PriceSize.small => 10,
        PriceSize.medium => 12,
        PriceSize.large => 16,
      };

  double get _currencySize => switch (size) {
        PriceSize.small => 11,
        PriceSize.medium => 13,
        PriceSize.large => 17,
      };

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textPrimary;
    final wholePart = price.truncate();
    final fractionPart = ((price - wholePart) * 100).round().toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strikethrough original price (if discounted)
        if (originalPrice != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 6),
            child: Text(
              '$currency${originalPrice!.toStringAsFixed(2)}',
              style: AppTypography.priceStrikethrough.copyWith(
                fontSize: _fractionSize,
              ),
            ),
          ),
        ],

        // Currency symbol
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            currency,
            style: TextStyle(
              fontFamily: AppTypography.fontBody,
              fontSize: _currencySize,
              fontWeight: FontWeight.w600,
              color: effectiveColor,
              height: 1.0,
            ),
          ),
        ),

        // Whole number
        Text(
          '$wholePart',
          style: TextStyle(
            fontFamily: AppTypography.fontBody,
            fontSize: _wholeSize,
            fontWeight: FontWeight.w700,
            color: effectiveColor,
            height: 1.0,
          ),
        ),

        // Decimal point + superscript pence
        Text(
          '.',
          style: TextStyle(
            fontFamily: AppTypography.fontBody,
            fontSize: _fractionSize,
            fontWeight: FontWeight.w600,
            color: effectiveColor,
            height: 1.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            fractionPart,
            style: TextStyle(
              fontFamily: AppTypography.fontBody,
              fontSize: _fractionSize,
              fontWeight: FontWeight.w600,
              color: effectiveColor,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}
