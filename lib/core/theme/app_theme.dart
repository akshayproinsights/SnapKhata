import 'package:flutter/material.dart';

/// Central theme configuration for SnapKhata.
class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF0066FF);

  static ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      );

  static ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
