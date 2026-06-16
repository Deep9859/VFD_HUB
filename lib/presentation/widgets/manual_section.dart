import 'package:flutter/material.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/vfd_manual.dart';

class ManualSection extends StatelessWidget {
  final List<VfdManual> manuals;
  final void Function(VfdManual manual)? onManualTap;

  const ManualSection({
    super.key,
    required this.manuals,
    this.onManualTap,
  });

  IconData _getManualIcon(String manualType) {
    switch (manualType.toLowerCase()) {
      case 'user manual':
        return Icons.menu_book;
      case 'quick start':
        return Icons.flash_on;
      case 'parameter guide':
        return Icons.list;
      case 'installation guide':
        return Icons.build;
      case 'troubleshooting':
        return Icons.help;
      default:
        return Icons.description;
    }
  }

  Color _getManualColor(String manualType, BuildContext context) {
    switch (manualType.toLowerCase()) {
      case 'user manual':
        return Colors.blue;
      case 'quick start':
        return Colors.orange;
      case 'parameter guide':
        return Colors.green;
      case 'installation guide':
        return Colors.purple;
      case 'troubleshooting':
        return Colors.red;
      default:
        return context.onSurfaceMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: manuals.map((manual) => _buildManualCard(context, manual, isDark)).toList(),
    );
  }

  Widget _buildManualCard(BuildContext context, VfdManual manual, bool isDark) {
    final color = _getManualColor(manual.manualType, context);

    return InkWell(
      onTap: () => onManualTap?.call(manual),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _getManualIcon(manual.manualType),
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manual.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.15),
                                color.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: color.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            manual.manualType,
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 12,
                                color: context.onSurfaceMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'v${manual.version}',
                                style: context.captionStyle?.copyWith(
                                  color: context.onSurfaceMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.successBg,
                      context.successColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.tintedBorder(context.successColor), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: context.successColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
