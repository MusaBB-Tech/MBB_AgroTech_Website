import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/constants/colors.dart';

enum ToastType { success, error, warning, info }

class CustomToast {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.success,
    int durationInSeconds = 3,
  }) {
    // Determine styling based on type
    late Color backgroundColor;
    late IconData icon;
    late Color textColor;
    late Color iconColor;

    switch (type) {
      case ToastType.success:
        backgroundColor = TColors.success.withOpacity(0.9);
        icon = Icons.check_circle_rounded;
        textColor = TColors.white;
        iconColor = TColors.white;
        break;
      case ToastType.error:
        backgroundColor = TColors.error.withOpacity(0.9);
        icon = Icons.error_rounded;
        textColor = TColors.white;
        iconColor = TColors.white;
        break;
      case ToastType.warning:
        backgroundColor = TColors.warning.withOpacity(0.9);
        icon = Icons.warning_rounded;
        textColor = TColors.white;
        iconColor = TColors.white;
        break;
      case ToastType.info:
        backgroundColor = TColors.info.withOpacity(0.9);
        icon = Icons.info_rounded;
        textColor = TColors.white;
        iconColor = TColors.white;
        break;
    }

    FToast fToast = FToast();
    fToast.init(context);

    // Animation controller setup
    final AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: Navigator.of(context),
    );

    // Scale animation with bounce effect
    final Animation<double> scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
          ),
        );

    // Fade animation
    final Animation<double> fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
          ),
        );

    // Slide animation from top with slight overshoot
    final Animation<Offset> slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.7, curve: Curves.bounceOut),
          ),
        );

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    // Wrap toast in animated transformations
    Widget animatedToast = AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: toast),
          ),
        );
      },
    );

    // Show toast and start animation
    fToast.showToast(
      child: animatedToast,
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: durationInSeconds),
      fadeDuration: const Duration(milliseconds: 300),
    );

    // Start animation and handle exit
    controller.forward().then((_) {
      Future.delayed(Duration(seconds: durationInSeconds), () {
        controller.reverse().then((_) {
          controller.dispose();
        });
      });
    });
  }

  // Convenience methods for each type (unchanged)
  static void success(
    BuildContext context,
    String message, {
    int duration = 3,
  }) {
    show(
      context,
      message,
      type: ToastType.success,
      durationInSeconds: duration,
    );
  }

  static void error(BuildContext context, String message, {int duration = 4}) {
    show(context, message, type: ToastType.error, durationInSeconds: duration);
  }

  static void warning(
    BuildContext context,
    String message, {
    int duration = 4,
  }) {
    show(
      context,
      message,
      type: ToastType.warning,
      durationInSeconds: duration,
    );
  }

  static void info(BuildContext context, String message, {int duration = 3}) {
    show(context, message, type: ToastType.info, durationInSeconds: duration);
  }
}
