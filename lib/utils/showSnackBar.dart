import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'constants/colors.dart';

enum SnackbarType { success, error, warning, info }

class CustomSnackbar {
  static void show(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.success,
    int durationInSeconds = 3,
    bool showCloseButton = true,
  }) {
    // Determine styling based on type
    late Color borderColor;
    late Color backgroundFillColor; // New color for the filled background
    late IconData icon;
    late Color iconColor;
    late Color textColor;

    switch (type) {
      case SnackbarType.success:
        borderColor = TColors.success.withOpacity(0.3);
        backgroundFillColor = TColors.success.withOpacity(
          0.6,
        ); // Lighter version
        icon = Icons.check_circle_rounded;
        iconColor = TColors.white;
        textColor = TColors.white;
        break;
      case SnackbarType.error:
        borderColor = TColors.error.withOpacity(0.3);
        backgroundFillColor = TColors.error.withOpacity(0.6);
        icon = Icons.error_rounded;
        iconColor = TColors.white;
        textColor = TColors.white;
        break;
      case SnackbarType.warning:
        borderColor = TColors.warning.withOpacity(0.3);
        backgroundFillColor = TColors.warning.withOpacity(0.6);
        icon = Icons.warning_rounded;
        iconColor = TColors.white;
        textColor = TColors.white;
        break;
      case SnackbarType.info:
        borderColor = TColors.info.withOpacity(0.3);
        backgroundFillColor = TColors.info.withOpacity(0.6);
        icon = Icons.info_rounded;
        iconColor = TColors.white;
        textColor = TColors.white;
        break;
    }

    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: backgroundFillColor, // Apply the lighter background color
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showCloseButton)
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: textColor.withOpacity(0.7),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: durationInSeconds),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      dismissDirection: DismissDirection.horizontal,
    );

    // Remove any current snackbar before showing new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
      type: SnackbarType.success,
      durationInSeconds: duration,
    );
  }

  static void error(BuildContext context, String message, {int duration = 4}) {
    show(
      context,
      message,
      type: SnackbarType.error,
      durationInSeconds: duration,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    int duration = 4,
  }) {
    show(
      context,
      message,
      type: SnackbarType.warning,
      durationInSeconds: duration,
    );
  }

  static void info(BuildContext context, String message, {int duration = 3}) {
    show(
      context,
      message,
      type: SnackbarType.info,
      durationInSeconds: duration,
    );
  }
}

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

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: durationInSeconds),
    );
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
