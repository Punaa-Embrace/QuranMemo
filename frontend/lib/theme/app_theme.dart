import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF188F48);
  static const Color backgroundColor = Color(0xFFF5E2D1);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color.fromARGB(255, 78, 143, 40);

  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.green,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
  );
}