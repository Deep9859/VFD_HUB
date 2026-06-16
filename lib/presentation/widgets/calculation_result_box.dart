import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_context.dart';

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
    final bg = context.tintedBg(accentColor);
    final border = context.tintedBorder(accentColor);
    final fg = context.onSurface;

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
