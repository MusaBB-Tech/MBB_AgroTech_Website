import 'package:flutter/material.dart';

class TchipTheme{
  TchipTheme._();

  // light theme
  static ChipThemeData lightChipTheme= const ChipThemeData(
    disabledColor: Colors.grey, //withOpacity(0.4),
    labelStyle: TextStyle(color: Colors.black),
    selectedColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 12.0,vertical: 12),
    checkmarkColor: Colors.white,
  );

  // dark theme
   static ChipThemeData darkChipTheme= const ChipThemeData(
    disabledColor: Colors.grey,
    labelStyle: TextStyle(color: Colors.white),
    selectedColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 12.0,vertical: 12),
    checkmarkColor: Colors.white,
  );
}