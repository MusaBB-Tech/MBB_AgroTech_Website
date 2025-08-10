import 'package:flutter/material.dart';

class TColors {
  TColors._();

  // App Basic Colors - MBB Agrotech Theme
  static const Color primary = Color(0xff2E7D32); // Deep Farm Green
  static const Color secondary = Color(0xffA5D6A7); // Soft Leaf Green
  static const Color accent = Color(0xffFFD54F); // Warm Golden Yellow

  // Text colors
  static const Color textprimary = Color(0xff1B1B1B); // Dark for light mode
  static const Color textsecondary = Color(0xff4E5D4E); // Muted green-gray
  static const Color textaWhite = Colors.white; // White for dark backgrounds

  // Background colors
  static const Color light = Color(0xffF4F8F4); // Soft green-tinted white
  static const Color dark = Color(0xff121212); // Dark mode background
  static const Color primaryBackground = Color(0xffFFFFFF); // White containers

  // Background container colors
  static const Color lightContainer = Color(0xffFFFFFF); // Light mode container
  static const Color darkContainer = Color(0xff1C1C1E); // Dark mode container

  // Button colors
  static const Color buttonPrimary = Color(0xff2E7D32); // Primary green
  static const Color buttonSecondary = Color(0xffA5D6A7); // Light green
  static const Color buttonDisabled = Color(0xffBDBDBD); // Gray for disabled

  // Border colors
  static const Color borderPrimary = Color(0xffC8E6C9); // Light green border
  static const Color borderSecondary = Color(0xffA5D6A7); // Medium green border

  // Error and validation colors
  static const Color error = Color(0xffD32F2F); // Red for errors
  static const Color success = Color(0xff388E3C); // Success green
  static const Color warning = Color(0xffFBC02D); // Golden warning
  static const Color info = Color(0xff0288D1); // Blue for info

  // Neutral shades
  static const Color black = Color(0xff000000); // Pure black
  static const Color darkerGrey = Color(0xff1C1C1E); // Dark gray
  static const Color darkGrey = Color(0xff2C2C2E); // Medium dark gray
  static const Color grey = Color(0xff757575); // Standard gray
  static const Color softgrey = Color(0xffE0E0E0); // Soft gray
  static const Color lightgrey = Color(0xffF5F5F5); // Very light gray
  static const Color white = Color(0xffFFFFFF); // Pure white

  // Gradient color
  static const Gradient linearGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff2E7D32), // Deep green
      Color(0xffA5D6A7), // Soft green
    ],
  );
}
