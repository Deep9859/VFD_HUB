import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_context.dart';

/// Progress bar + step chips for the VFD setup wizard on home.
class ConfigurationProgressHeader extends StatelessWidget {
  final int completedSteps;
  final int totalSteps;
  final int activeStep;

  const ConfigurationProgressHeader({
    super.key,
    required this.completedSteps,
    required this.totalSteps,
    required this.activeStep,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = totalSteps == 0 ? 0.0 : completedSteps / totalSteps;
    final cs = context.cs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.configProgressLabel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.onSurfaceMuted,
                ),
              ),
            ),
            Text(
              l10n.stepCounter(activeStep, totalSteps),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(totalSteps, (i) {
              final step = i + 1;
              final done = completedSteps >= step;
              final active = activeStep == step;
              return Padding(
                padding: EdgeInsets.only(right: i < totalSteps - 1 ? 8 : 0),
                child: _StepChip(
                  step: step,
                  label: _shortLabel(l10n, step),
                  done: done,
                  active: active,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  String _shortLabel(AppLocalizations l10n, int step) {
    switch (step) {
      case 1:
        return l10n.vendor;
      case 2:
        return l10n.model;
      case 3:
        return l10n.powerRatingLabel;
      case 4:
        return l10n.voltageStepTitle;
      case 5:
        return l10n.connectionStepTitle;
      case 6:
        return l10n.parametersStepTitle;
      default:
        return '';
    }
  }
}

class _StepChip extends StatelessWidget {
  final int step;
  final String label;
  final bool done;
  final bool active;

  const _StepChip({
    required this.step,
    required this.label,
    required this.done,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    Color bg;
    Color fg;
    Color border;

    if (done) {
      bg = AppTheme.success.withOpacity(0.12);
      fg = AppTheme.success;
      border = AppTheme.success.withOpacity(0.35);
    } else if (active) {
      bg = cs.primary.withOpacity(0.12);
      fg = cs.primary;
      border = cs.primary;
    } else {
      bg = cs.surfaceContainerHighest;
      fg = context.onSurfaceMuted;
      border = cs.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: active ? 1.5 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: done
                ? AppTheme.success
                : (active ? cs.primary : cs.outline),
            child: done
                ? Icon(Icons.check, size: 12, color: cs.onPrimary)
                : Text(
                    '$step',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimary,
                    ),
                  ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: active || done ? FontWeight.w600 : FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Short hint shown under an active configuration step.
class StepGuideBanner extends StatelessWidget {
  final String message;

  const StepGuideBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.accent.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 18,
            color: AppTheme.accent.withOpacity(0.9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.4,
                color: context.onSurfaceMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
