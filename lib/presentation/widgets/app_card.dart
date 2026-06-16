import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_context.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? accentColor;
  final Color? backgroundColor;
  final Color? iconBackgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool showGradient;
  final bool glassmorphism;
  final int? stepNumber;
  final int? stepTotal;
  final bool isActiveStep;
  final bool isCompletedStep;

  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.accentColor,
    this.backgroundColor,
    this.iconBackgroundColor,
    this.titleColor,
    this.subtitleColor,
    this.elevation,
    this.padding,
    this.borderRadius,
    this.showGradient = false,
    this.glassmorphism = false,
    this.stepNumber,
    this.stepTotal,
    this.isActiveStep = false,
    this.isCompletedStep = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.cs;
    final color = accentColor ?? cs.primary;
    final bgColor = backgroundColor ?? cs.surface;
    final highlight = isCompletedStep
        ? AppTheme.success
        : (isActiveStep ? cs.primary : null);
    final borderColor = highlight ?? cs.outline;

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: showGradient && !isDark
            ? Color.lerp(bgColor, color.withOpacity(0.04), 0.5)
            : bgColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: highlight ?? borderColor,
          width: highlight != null ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (highlight ?? Colors.black).withOpacity(
              highlight != null ? 0.12 : (isDark ? 0.2 : 0.04),
            ),
            blurRadius: highlight != null ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || subtitle != null || icon != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (stepNumber != null) ...[
                  _StepBadge(
                    number: stepNumber!,
                    total: stepTotal,
                    done: isCompletedStep,
                    active: isActiveStep,
                  ),
                  const SizedBox(width: 10),
                ],
                if (icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (iconBackgroundColor ?? color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: titleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: subtitleColor ?? context.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int number;
  final int? total;
  final bool done;
  final bool active;

  const _StepBadge({
    required this.number,
    this.total,
    required this.done,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final bg = done
        ? context.successColor
        : (active ? context.cs.primary : context.surfaceMuted);
    final fg =
        done || active ? context.onPrimaryBg : context.onSurfaceMuted;

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: done
          ? Icon(Icons.check, color: fg, size: 18)
          : Text(
              total != null ? '$number/$total' : '$number',
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: total != null ? 11 : 14,
              ),
            ),
    );
  }
}
