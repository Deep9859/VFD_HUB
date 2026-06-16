import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_form_styles.dart';

class AppTheme {
  // ── Brand Colors ──────────────────────────────────────────────────
  static const Color primary      = Color(0xFF1B4F8A);
  static const Color primaryDark  = Color(0xFF0F3460);
  static const Color primaryLight = Color(0xFF2E6DB4);
  static const Color primaryBlue  = primary;
  static const Color secondaryPurple = Color(0xFF6B46C1);
  static const Color accent       = Color(0xFF00A8E8);
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

  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkSurfaceHigh = Color(0xFF2A2A3E);
  static const Color darkOutline = Color(0xFF3A3A4E);
  static const Color darkPrimary = Color(0xFF5B9BD5);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light Theme ───────────────────────────────────────────────────
  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    scheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: accent,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: grey900,
      surfaceContainerHighest: grey100,
      onSurfaceVariant: grey500,
      outline: grey300,
      outlineVariant: grey200,
      error: error,
      onError: Colors.white,
    ),
    scaffoldBg: grey50,
    appBarBg: Colors.white,
    appBarFg: grey900,
    cardBg: Colors.white,
    cardBorder: grey200,
    inputFill: grey100,
    inputBorder: grey300,
    inputFocus: primary,
    inputLabel: grey500,
    inputHint: grey400,
    inputError: error,
    chipBg: grey100,
    chipLabel: grey700,
    divider: grey200,
    navBg: Colors.white,
    navSelected: primary,
    navUnselected: grey500,
  );

  // ── Dark Theme ────────────────────────────────────────────────────
  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    scheme: const ColorScheme.dark(
      primary: darkPrimary,
      onPrimary: Colors.white,
      secondary: accent,
      onSecondary: Colors.white,
      surface: darkSurface,
      onSurface: Colors.white,
      surfaceContainerHighest: darkSurfaceHigh,
      onSurfaceVariant: Color(0xFF8080A0),
      outline: darkOutline,
      outlineVariant: Color(0xFF2A2A3E),
      error: Color(0xFFFF6B6B),
      onError: Colors.white,
    ),
    scaffoldBg: const Color(0xFF13131F),
    appBarBg: darkSurface,
    appBarFg: Colors.white,
    cardBg: darkSurface,
    cardBorder: darkSurfaceHigh,
    inputFill: darkSurfaceHigh,
    inputBorder: darkOutline,
    inputFocus: darkPrimary,
    inputLabel: Color(0xFF8080A0),
    inputHint: Color(0xFF606080),
    inputError: Color(0xFFFF6B6B),
    chipBg: darkSurfaceHigh,
    chipLabel: Colors.white70,
    divider: darkSurfaceHigh,
    navBg: darkSurface,
    navSelected: darkPrimary,
    navUnselected: Color(0xFF8080A0),
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffoldBg,
    required Color appBarBg,
    required Color appBarFg,
    required Color cardBg,
    required Color cardBorder,
    required Color inputFill,
    required Color inputBorder,
    required Color inputFocus,
    required Color inputLabel,
    required Color inputHint,
    required Color inputError,
    required Color chipBg,
    required Color chipLabel,
    required Color divider,
    required Color navBg,
    required Color navSelected,
    required Color navUnselected,
  }) {
    final base = scheme.onSurface;
    final textTheme = _textTheme(base);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: appBarFg,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
        actionsIconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cardBorder),
        ),
        color: cardBg,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: AppFormStyles.inputTheme(
        isDark: brightness == Brightness.dark,
        fillColor: inputFill,
        borderColor: inputBorder,
        focusColor: inputFocus,
        labelColor: inputLabel,
        hintColor: inputHint,
        errorColor: inputError,
      ).copyWith(
        labelStyle: GoogleFonts.inter(fontSize: 13, height: 1.2, color: inputLabel),
        floatingLabelStyle:
            GoogleFonts.inter(fontSize: 13, height: 1.2, color: inputLabel),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: inputHint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withOpacity(0.4),
          disabledForegroundColor: scheme.onPrimary.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          disabledForegroundColor: scheme.onSurface.withOpacity(0.38),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide(color: scheme.primary),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          disabledForegroundColor: scheme.onSurface.withOpacity(0.38),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
        ),
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 0),
      chipTheme: ChipThemeData(
        backgroundColor: chipBg,
        labelStyle:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: chipLabel),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: cardBg,
        collapsedBackgroundColor: cardBg,
        iconColor: scheme.onSurfaceVariant,
        collapsedIconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        collapsedTextColor: scheme.onSurface,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyLarge,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBg,
        selectedItemColor: navSelected,
        unselectedItemColor: navUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle:
            GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brightness == Brightness.dark ? darkSurfaceHigh : grey900,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        actionTextColor: scheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static TextTheme _textTheme(Color base) => GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.inter(
            fontSize: 28, fontWeight: FontWeight.w700, color: base, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.w700, color: base, letterSpacing: -0.3),
        headlineSmall: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w600, color: base, letterSpacing: -0.2),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: base),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: base),
        titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: base),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: base),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: base),
        bodySmall: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w400, color: base.withOpacity(0.7)),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: base),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: base),
        labelSmall: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500, color: base.withOpacity(0.7)),
      );
}
