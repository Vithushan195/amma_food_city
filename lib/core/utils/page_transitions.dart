import 'package:flutter/material.dart';

/// Slide-up page transition for modal-style screens (checkout, detail).
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOut));
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

/// Fade-scale transition for overlays (dialogs, bottom sheets).
class FadeScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeScaleRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleTween = Tween(begin: 0.9, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut));
            return ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
}

/// Shared axis horizontal transition for peer navigation.
class SharedAxisRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SharedAxisRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideTween = Tween(begin: const Offset(0.05, 0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOut));
            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
