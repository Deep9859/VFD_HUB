import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Theme-aware colors and text — use instead of hardcoded [Colors.grey] / [Colors.white].
extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get cs => theme.colorScheme;
  TextTheme get txt => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Body text on surfaces (cards, scaffold).
  Color get onSurface => cs.onSurface;

  /// Secondary / caption text.
  Color get onSurfaceMuted => cs.onSurfaceVariant;

  /// Hints, placeholders, disabled labels.
  Color get onSurfaceSubtle =>
      cs.onSurface.withOpacity(isDarkMode ? 0.45 : 0.55);

  /// Card / tile background.
  Color get surfaceCard => cs.surface;

  /// Slightly elevated / inset surface (dropdowns, chips).
  Color get surfaceMuted => cs.surfaceContainerHighest;

  /// Borders on cards and tiles.
  Color get borderColor => cs.outline;

  /// Empty-state panel background.
  Color get emptyStateBg => surfaceMuted;

  /// Text on primary-colored headers and filled buttons.
  Color get onPrimaryBg => cs.onPrimary;

  /// Icon on primary-colored backgrounds.
  Color get onPrimaryIcon => cs.onPrimary;

  TextStyle? get titleStyle => txt.titleMedium;
  TextStyle? get bodyStyle => txt.bodyMedium;
  TextStyle? get captionStyle => txt.bodySmall;
  TextStyle? get labelStyle => txt.labelMedium;

  /// SnackBar / status colors (semantic, not theme surface).
  Color get successColor => AppTheme.success;
  Color get warningColor => AppTheme.warning;
  Color get errorColor => cs.error;
  Color get infoColor => cs.primary;

  /// Tinted banner / chip backgrounds for semantic states.
  Color tintedBg(Color base) =>
      base.withOpacity(isDarkMode ? 0.2 : 0.1);

  Color tintedBorder(Color base) =>
      base.withOpacity(isDarkMode ? 0.55 : 0.4);

  Color get successBg => tintedBg(successColor);
  Color get warningBg => tintedBg(warningColor);
  Color get infoBg => tintedBg(infoColor);
  Color get errorBg => tintedBg(errorColor);
}
