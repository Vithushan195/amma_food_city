import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Gromuse-style curved header with dark green gradient.
/// Use as the top section of screens like Home, Categories, Cart.
///
/// ```dart
/// CurvedHeader(
///   height: 200,
///   child: Column(
///     children: [
///       Text('Amma Food City', style: AppTypography.sectionHeaderWhite),
///       SearchBarWidget(),
///     ],
///   ),
/// )
/// ```
class CurvedHeader extends StatelessWidget {
  final double height;
  final Widget child;
  final EdgeInsets? padding;

  const CurvedHeader({
    super.key,
    this.height = AppSpacing.headerCurveHeight,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurvedClipper(curveRadius: AppSpacing.headerCurveRadius),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
        ),
        padding: padding ??
            const EdgeInsets.fromLTRB(
              AppSpacing.headerContentPadding,
              AppSpacing.xxxl, // account for status bar
              AppSpacing.headerContentPadding,
              AppSpacing.xxl, // space before curve cutoff
            ),
        child: child,
      ),
    );
  }
}

class _CurvedClipper extends CustomClipper<Path> {
  final double curveRadius;

  _CurvedClipper({required this.curveRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - curveRadius);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + curveRadius * 0.6,
      size.width,
      size.height - curveRadius,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _CurvedClipper oldClipper) =>
      curveRadius != oldClipper.curveRadius;
}
