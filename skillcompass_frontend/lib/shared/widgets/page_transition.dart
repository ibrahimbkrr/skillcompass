import 'package:flutter/material.dart';

/// Animasyonlu sayfa geçişleri için yardımcı sınıf
class PageTransitions {
  /// Sağdan sola kaydırma animasyonu (varsayılan)
  static Route<T> slideRight<T>(Widget page, {int milliseconds = 300}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: Duration(milliseconds: milliseconds),
    );
  }

  /// Alttan yukarı kayma animasyonu
  static Route<T> slideUp<T>(Widget page, {int milliseconds = 300}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: Duration(milliseconds: milliseconds),
    );
  }

  /// Fade (soluma) animasyonu
  static Route<T> fade<T>(Widget page, {int milliseconds = 300}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: Duration(milliseconds: milliseconds),
    );
  }

  /// Scale (büyüme) animasyonu
  static Route<T> scale<T>(Widget page, {int milliseconds = 300}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOutQuart;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var scaleAnimation = animation.drive(tween);

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: milliseconds),
    );
  }

  /// Rotation (dönme) ve scale (büyüme) animasyonu
  static Route<T> rotateScale<T>(Widget page, {int milliseconds = 400}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(begin: 0.2, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuad,
            ),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutQuad,
              ),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
              ),
              child: child,
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: milliseconds),
    );
  }

  /// Sayfa yenileme/güncelleme animasyonu (sayfayı yenilemek istediğinizde)
  static Route<T> refresh<T>(Widget page, {int milliseconds = 500}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
            ),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: milliseconds),
    );
  }
}

/// Hızlıca kullanabileceğiniz sayfa geçiş widget'ı
class AnimatedPage extends StatelessWidget {
  final Widget child;
  final int durationMillis;

  const AnimatedPage({
    super.key,
    required this.child,
    this.durationMillis = 400,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: durationMillis),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeInOutCubic,
      builder: (context, value, childWidget) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
} 