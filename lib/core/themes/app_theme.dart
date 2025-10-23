import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F1C2E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F1C2E),
        elevation: 0,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00CFC3),
      ),
    );
  }
}
