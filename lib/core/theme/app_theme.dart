import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Complete, production-quality Material 3 Theme matching the Thiral brand palette.
class AppTheme {
  AppTheme._();

  // ─── Brand Colors (Only defined here) ───
  static const Color _primaryNavy = Color(0xFF0B1E36);
  static const Color _flameOrange = Color(0xFFF07020);
  static const Color _flameGold = Color(0xFFF5C518);
  static const Color _success = Color(0xFF2ECC71);
  static const Color _error = Color(0xFFE74C3C);

  // ─── Shared Color Schemes ───
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _flameOrange,
    primary: _flameOrange,
    secondary: _flameGold,
    tertiary: _primaryNavy,
    error: _error,
    surface: Colors.white,
    brightness: Brightness.light,
  );

  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _flameOrange,
    primary: _flameOrange,
    secondary: _flameGold,
    tertiary: Colors.white,
    error: _error,
    surface: _primaryNavy, // Dark theme uses primaryNavy as background
    brightness: Brightness.dark,
  );

  // ─── Light Theme ───
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: Colors.grey.shade50,
      textTheme: _buildTextTheme(_lightColorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _primaryNavy,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _flameOrange,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _flameOrange.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: _primaryNavy),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _flameOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _flameOrange,
          side: const BorderSide(color: _flameOrange, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _flameOrange,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _flameOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error),
        ),
        labelStyle: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 14),
        hintStyle: GoogleFonts.nunito(color: Colors.grey.shade400, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _primaryNavy.withValues(alpha: 0.05),
        labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: _primaryNavy),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
      ),
    );
  }

  // ─── Dark Theme ───
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: _primaryNavy, // Requirements: background is primaryNavy
      textTheme: _buildTextTheme(_darkColorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _primaryNavy,
        selectedItemColor: _flameOrange,
        unselectedItemColor: Colors.white60,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _primaryNavy,
        indicatorColor: _flameOrange.withValues(alpha: 0.2),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF152A4A), // Slightly lighter than primaryNavy for contrast
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _flameOrange,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _flameOrange,
          side: const BorderSide(color: _flameOrange, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _flameOrange,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF152A4A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _flameOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error),
        ),
        labelStyle: GoogleFonts.nunito(color: Colors.white70, fontSize: 14),
        hintStyle: GoogleFonts.nunito(color: Colors.white54, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _flameOrange.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: _flameOrange),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
      ),
    );
  }

  // ─── Text Theme (Poppins for Headings, Nunito for Body) ───
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final textColor = colorScheme.brightness == Brightness.light ? _primaryNavy : Colors.white;
    final fallback = const <String>['Noto Sans Tamil']; // Ensures Tamil script fallback

    return TextTheme(
      // Headings (Poppins)
      displayLarge: GoogleFonts.poppins(
        fontSize: 32, fontWeight: FontWeight.bold, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28, fontWeight: FontWeight.bold, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24, fontWeight: FontWeight.w600, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22, fontWeight: FontWeight.w600, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.w600, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w600, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w600, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w600, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),
      titleSmall: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w500, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),

      // Body (Nunito)
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16, fontWeight: FontWeight.normal, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14, fontWeight: FontWeight.normal, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12, fontWeight: FontWeight.normal, color: textColor.withValues(alpha: 0.8),
      ).copyWith(fontFamilyFallback: fallback),

      // Labels (Nunito)
      labelLarge: GoogleFonts.nunito(
        fontSize: 14, fontWeight: FontWeight.w600, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),
      labelMedium: GoogleFonts.nunito(
        fontSize: 12, fontWeight: FontWeight.w600, color: textColor,
      ).copyWith(fontFamilyFallback: fallback),
      labelSmall: GoogleFonts.nunito(
        fontSize: 10, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.7),
      ).copyWith(fontFamilyFallback: fallback),
    );
  }
}
