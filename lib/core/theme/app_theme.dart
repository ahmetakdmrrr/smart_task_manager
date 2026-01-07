import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uygulama tema yapılandırması - Premium Dark Orange & Neon
class AppTheme {
  // Renk Paleti
  static const Color _primaryOrange = Color(0xFFFF6D00); // Koyu Turuncu
  static const Color _neonOrange = Color(0xFFFF9E80);    // Neonumsu Açık Turuncu
  static const Color _backgroundDark = Color(0xFF121212); // Derin Siyah
  static const Color _surfaceDark = Color(0xFF1E1E1E);    // Kart Rengi
  static const Color _neonRed = Color(0xFFFF1744);        // Yüksek Öncelik
  static const Color _neonYellow = Color(0xFFFFC400);     // Orta Öncelik
  static const Color _neonGreen = Color(0xFF00E676);      // Düşük Öncelik

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _backgroundDark,
      
      // Font Ailesi
      fontFamily: GoogleFonts.outfit().fontFamily,
      
      // Renk Şeması
      colorScheme: const ColorScheme.dark(
        primary: _primaryOrange,
        secondary: _neonOrange,
        surface: _surfaceDark,
        background: _backgroundDark,
        error: _neonRed,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),

      // AppBar Teması
      appBarTheme: AppBarTheme(
        backgroundColor: _backgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: _primaryOrange),
      ),

      // Kart Teması
      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Input Alanı Teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _neonRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),

      // Buton Teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryOrange,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryOrange,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Dialog Teması
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Chip Teması (Filtreler için)
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceDark,
        labelStyle: const TextStyle(color: Colors.white),
        secondarySelectedColor: _primaryOrange.withOpacity(0.2),
        secondaryLabelStyle: const TextStyle(color: _primaryOrange),
        selectedColor: _primaryOrange,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }

  // Renk Getiriciler
  static Color get priorityHigh => _neonRed;
  static Color get priorityMedium => _neonYellow;
  static Color get priorityLow => _neonGreen;
}
