import 'package:flutter/material.dart';

// ignore: unused_element
final ThemeData _industrialDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1F2A30),
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF2BB4AA),
    onPrimary: Colors.black,
    secondary: Color(0xFF4FB3C8),
    onSecondary: Colors.black,
    surface: Color(0xFF2A343B),
    onSurface: Color(0xFFD9E1E8),
    error: Color(0xFFD35B5B),
    onError: Colors.black,
    tertiary: Color(0xFF77C66E),
    onTertiary: Colors.black,
    surfaceContainerHighest: Color(0xFF36424A),
    onSurfaceVariant: Color(0xFFC7D1D8),
    outline: Color(0xFF42535B),
    outlineVariant: Color(0xFF42535B),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFD9E1E8),
    onInverseSurface: Color(0xFF2A343B),
    inversePrimary: Color(0xFF4FB3C8),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2A343B),
    foregroundColor: Color(0xFFD9E1E8),
    elevation: 0,
    centerTitle: false,
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF2A343B),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      side: BorderSide(color: Color(0xFF42535B), width: 1),
    ),
    elevation: 0,
    margin: EdgeInsets.zero,
  ),
  dataTableTheme: const DataTableThemeData(
    headingRowColor: WidgetStatePropertyAll(Color(0xFF36424A)),
    dataRowColor: WidgetStatePropertyAll(Color(0xFF2A343B)),
    headingTextStyle: TextStyle(
      color: Color(0xFFD9E1E8),
      fontWeight: FontWeight.w600,
    ),
    dataTextStyle: TextStyle(color: Color(0xFFC7D1D8)),
    dividerThickness: .5,
  ),
  chipTheme: const ChipThemeData(
    backgroundColor: Color(0xFF36424A),
    labelStyle: TextStyle(color: Color(0xFFD9E1E8)),
    side: BorderSide(color: Color(0xFF42535B)),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Color(0xFF2BB4AA)),
      foregroundColor: const WidgetStatePropertyAll(Colors.black),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevation: const WidgetStatePropertyAll(0),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A343B),
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF42535B)),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF42535B)),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF2BB4AA), width: 1.2),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFF42535B), thickness: .6),
  iconTheme: const IconThemeData(color: Color(0xFFC7D1D8)),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontWeight: FontWeight.w700,
      color: Color(0xFFD9E1E8),
    ),
    bodyMedium: TextStyle(color: Color(0xFFC7D1D8)),
    labelLarge: TextStyle(color: Color(0xFFAEB8BF)),
  ),
);
