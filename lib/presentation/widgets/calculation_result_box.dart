import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Theme-aware panel for calculator output — readable in light and dark mode.
class CalculationResultBox extends StatelessWidget {
  final String text;
  final Color accentColor;
  final double fontSize;
  final FontWeight fontWeight;

  const CalculationResultBox({
    super.key,
    required this.text,
    this.accentColor = AppTheme.success,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? accentColor.withOpacity(0.2)
        : accentColor.withOpacity(0.1);
    final border = accentColor.withOpacity(isDark ? 0.55 : 0.4);
    final fg = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1.5,
          color: fg,
        ),
      ),
    );
  }
}
