import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_form_styles.dart';

class AppTheme {
  // ── Brand Colors ──────────────────────────────────────────────────
  static const Color primary      = Color(0xFF1B4F8A); // Navy Blue
  static const Color primaryDark  = Color(0xFF0F3460);
  static const Color primaryLight = Color(0xFF2E6DB4);
  static const Color primaryBlue  = primary; // Alias for compatibility
  static const Color secondaryPurple = Color(0xFF6B46C1); // Purple accent
  static const Color accent       = Color(0xFF00A8E8); // Cyan accent
  static const Color success      = Color(0xFF27AE60);
  static const Color warning      = Color(0xFFF39C12);
  static const Color error        = Color(0xFFE74C3C);

  // ── Neutral ───────────────────────────────────────────────────────
  static const Color grey50  = Color(0xFFF8F9FA);
  static const Color grey100 = Color(0xFFF1F3F5);
  static const Color grey200 = Color(0xFFE9ECEF);
  static const Color grey300 = Color(0xFFDEE2E6);
  static const Color grey400 = Color(0xFFADB5BD);
  static const Color grey500 = Color(0xFF6C757D);
  static const Color grey700 = Color(0xFF495057);
  static const Color grey900 = Color(0xFF212529);

  // ── Gradients ─────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light Theme ───────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      error: error,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: grey900,
    ),
    scaffoldBackgroundColor: grey50,
    textTheme: _textTheme(grey900),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.white,
      foregroundColor: grey900,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: grey900,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: grey700, size: 22),
      actionsIconTheme: const IconThemeData(color: grey700, size: 22),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: grey200),
      ),
      color: Colors.white,
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: AppFormStyles.inputTheme(
      isDark: false,
      fillColor: grey100,
      borderColor: grey300,
      focusColor: primary,
      labelColor: grey500,
      hintColor: grey400,
      errorColor: error,
    ).copyWith(
      labelStyle: GoogleFonts.inter(fontSize: 13, height: 1.2, color: grey500),
      floatingLabelStyle: GoogleFonts.inter(fontSize: 13, height: 1.2, color: grey500),
      hintStyle: GoogleFonts.inter(fontSize: 14, color: grey400),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: primary),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: const DividerThemeData(color: grey200, thickness: 1, space: 0),
    chipTheme: ChipThemeData(
      backgroundColor: grey100,
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: grey700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  // ── Dark Theme ────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF5B9BD5),
      secondary: accent,
      error: Color(0xFFFF6B6B),
      surface: Color(0xFF1E1E2E),
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF13131F),
    textTheme: _textTheme(Colors.white),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: const Color(0xFF1E1E2E),
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: Color(0xFFB0B0C0), size: 22),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2A2A3E)),
      ),
      color: const Color(0xFF1E1E2E),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: AppFormStyles.inputTheme(
      isDark: true,
      fillColor: const Color(0xFF2A2A3E),
      borderColor: const Color(0xFF3A3A4E),
      focusColor: const Color(0xFF5B9BD5),
      labelColor: const Color(0xFF8080A0),
      hintColor: const Color(0xFF606080),
      errorColor: const Color(0xFFFF6B6B),
    ).copyWith(
      labelStyle: GoogleFonts.inter(fontSize: 13, height: 1.2, color: const Color(0xFF8080A0)),
      floatingLabelStyle: GoogleFonts.inter(fontSize: 13, height: 1.2, color: const Color(0xFF8080A0)),
      hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF606080)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: const Color(0xFF5B9BD5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF5B9BD5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Color(0xFF5B9BD5)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF5B9BD5),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF2A2A3E), thickness: 1, space: 0),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2A2A3E),
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF5B9BD5),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  static TextTheme _textTheme(Color base) => GoogleFonts.interTextTheme().copyWith(
    headlineLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: base, letterSpacing: -0.5),
    headlineMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: base, letterSpacing: -0.3),
    headlineSmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: base, letterSpacing: -0.2),
    titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: base),
    titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: base),
    titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: base),
    bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: base),
    bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: base),
    bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: base.withOpacity(0.7)),
    labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: base),
    labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: base),
    labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: base.withOpacity(0.7)),
  );
}
