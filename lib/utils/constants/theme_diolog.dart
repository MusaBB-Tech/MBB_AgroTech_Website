import 'package:flutter/material.dart';

import '../helpers/helper_functions.dart';
import 'colors.dart';

Future<void> ThemeDialog({
  required BuildContext context,
  required String title,
  required Function(String) onModeSelected,
}) async {
  String? selectedMode; // Default value

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      final dark = THelperFunctions.isDarkMode(context);
      final textColor = dark ? TColors.light : TColors.dark;

      return AlertDialog(
        backgroundColor: dark ? TColors.dark : TColors.light,
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedMode,
              decoration: InputDecoration(
                labelText: 'Select Theme Mode',
                labelStyle: TextStyle(color: textColor),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: TColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: TColors.primary),
                ),
                filled: true,
                fillColor: dark
                    ? TColors.dark.withOpacity(0.8)
                    : TColors.light.withOpacity(0.8),
              ),
              dropdownColor: dark ? TColors.dark : TColors.light,
              style: TextStyle(color: textColor),
              items: const [
                DropdownMenuItem(
                  value: 'ThemeMode.system',
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: 'ThemeMode.light',
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: 'ThemeMode.dark',
                  child: Text('Dark'),
                ),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  selectedMode = value;
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Select your preferred theme mode.',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: textColor),
            ),
          ),
          TextButton(
            onPressed: () {
              if (selectedMode != null) {
                onModeSelected(
                    selectedMode!); // Call the callback with the selected mode
                Navigator.of(context).pop(); // Close the dialog
              } else {
                // Show a snackbar if no theme is selected
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please select a theme mode.',
                      style: TextStyle(color: TColors.light),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Apply',
              style: TextStyle(color: TColors.primary),
            ),
          ),
        ],
      );
    },
  );
}
