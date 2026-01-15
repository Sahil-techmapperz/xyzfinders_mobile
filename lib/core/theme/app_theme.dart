import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors (Refined for Premium Feel)
  static const Color primaryColor = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF60A5FA);
  
  // Accent Colors
  static const Color accentColor = Color(0xFF10B981); // Emerald
  static const Color accentDark = Color(0xFF059669);
  static const Color accentLight = Color(0xFF34D399);
  
  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textHint = Color(0xFF94A3B8); // Slate 400
  
  // Border Colors
  static const Color borderColor = Color(0xFFE2E8F0); // Slate 200
  static const Color dividerColor = Color(0xFFE2E8F0);
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: GoogleFonts.poppinsTextTheme(),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryLight,
      secondary: accentColor,
      secondaryContainer: accentLight,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: const CardThemeData(
      color: surfaceColor,
      elevation: 0, // Flat design with border
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: borderColor),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textHint),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: borderColor),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );
  
  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryLight,
      primaryContainer: primaryDark,
      secondary: accentLight,
      secondaryContainer: accentDark,
      surface: const Color(0xFF1E293B), // Slate 800
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: Color(0xFF334155)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF1E293B),
      selectedItemColor: primaryLight,
      unselectedItemColor: Color(0xFF94A3B8),
      elevation: 0,
    ),
  );
}
