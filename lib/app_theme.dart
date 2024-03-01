import 'dart:ui';

import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFF8BBD0); // A shade of pink
  static Color secondaryGreen = Colors.blue.shade800; // A shade of green

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPink,
      brightness: Brightness.dark, // Ensure dark mode
      primary: primaryPink,
      secondary: secondaryGreen,
    ),
    useMaterial3: true,
  );
}
