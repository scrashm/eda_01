import 'package:flutter/material.dart';

class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required WidgetBuilder builder,
  }) : super(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          pageBuilder: (context, __, ___) => builder(context),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            final slide = Tween<Offset>(
              begin: const Offset(0.03, 0.02),
              end: Offset.zero,
            ).animate(fade);

            return FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: child,
              ),
            );
          },
        );
}
