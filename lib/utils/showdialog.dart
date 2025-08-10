import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'helpers/helper_functions.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String hintText,
  required Function(String) onSubmit,
  Function? onCancel,
  int maxLines = 1, // Added support for multiline input
  TextInputType keyboardType =
      TextInputType.text, // Added keyboard type customization
}) async {
  final TextEditingController textController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      final bool isDarkMode = THelperFunctions.isDarkMode(context);

      return AlertDialog(
        backgroundColor: isDarkMode ? TColors.dark : TColors.light,
        title: Text(title),
        content: TextField(
          controller: textController,
          maxLines: maxLines, // Allow multiline input
          keyboardType: keyboardType, // Customize keyboard type
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: TColors.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: TColors.primary, width: 2.0),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              textController.clear(); // Clear the text field
              if (onCancel != null) {
                onCancel();
              }
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () {
              final String inputText = textController.text.trim();
              if (inputText.isNotEmpty) {
                onSubmit(inputText); // Submit only if input is not empty
                textController.clear(); // Clear the text field
                Navigator.of(context).pop();
              } else {
                // Show an error message or hint if input is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter some text.'),
                  ),
                );
              }
            },
            child: Text(
              'Submit',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      );
    },
  );
}
