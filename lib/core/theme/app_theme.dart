import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF005251); // Deep Teal
  static const Color secondaryColor = Color(0xFFFE8B53); // Vibrant Orange
  static const Color backgroundColor = Color(0xFFFFFCF3); // Warm Off-White
  static const Color surfaceColor = Colors.white;
  static const Color textColor = Color(0xFF171717); // Dark Gray
  static const Color textLightColor = Color(0xFF6B7280); // Gray 500

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    canvasColor: backgroundColor, // Important for some material widgets
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textColor,
      onSurface: textColor,
      error: Color(0xFFDC2626),
    ),
    
    // Typography
    textTheme: GoogleFonts.jostTextTheme().copyWith(
      displayLarge: const TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      displayMedium: const TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      displaySmall: const TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headlineMedium: const TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleLarge: const TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      bodyLarge: const TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      bodyMedium: const TextStyle(
        color: textColor,
        fontSize: 14,
      ),
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red),
      ),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Jost',
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Jost',
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Jost',
        ),
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: textColor,
      size: 24,
    ),
  );

  // Dark Theme (Keeping consistent with Light theme logic but adapted)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Color(0xFF1E293B),
    ),
    textTheme: GoogleFonts.jostTextTheme(ThemeData.dark().textTheme),
    // Re-use shapes/padding from light theme
    inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
       fillColor: const Color(0xFF1E293B),
       enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
    ),
  );
}
