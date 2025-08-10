import 'package:flutter/material.dart';

import 'constants/colors.dart';

enum SnackbarType { success, error, warning }

void showCustomSnackbar(
  BuildContext context,
  String message, {
  SnackbarType type = SnackbarType.success,
  int durationInSeconds = 3,
}) {
  // Determine styling based on type
  late Color backgroundColor;
  late IconData icon;
  late Color iconColor;

  switch (type) {
    case SnackbarType.success:
      backgroundColor = Colors.green;
      icon = Icons.check_circle;
      iconColor = TColors.white;
      break;
    case SnackbarType.error:
      backgroundColor = Colors.red;
      icon = Icons.error;
      iconColor = TColors.white;
      break;
    case SnackbarType.warning:
      backgroundColor = Colors.orange;
      icon = Icons.warning;
      iconColor = TColors.white;
      break;
  }

  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(message, style: TextStyle(color: TColors.white)),
        ),
      ],
    ),
    backgroundColor: backgroundColor,
    duration: Duration(seconds: durationInSeconds),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    elevation: 6,
  );

  // Remove any current snackbar before showing new one
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
