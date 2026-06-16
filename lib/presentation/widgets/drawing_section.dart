import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/vfd_drawing.dart';

class DrawingSection extends StatelessWidget {
  final List<VfdDrawing> drawings;
  final bool canUpload;
  final VoidCallback onUpload;
  final Function(VfdDrawing) onDelete;
  final Function(VfdDrawing) onOpen;

  const DrawingSection({
    super.key,
    required this.drawings,
    this.canUpload = true,
    required this.onUpload,
    required this.onDelete,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [context.cs.surface, context.cs.surfaceContainerHigh]
              : [context.surfaceCard, context.warningBg.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? context.borderColor : context.warningColor.withOpacity(0.35),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade600,
                          Colors.orange.shade700
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade600.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.architecture,
                        color: context.onPrimaryBg, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.drawings,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                      ),
                      Text(
                        '${drawings.length} file${drawings.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (canUpload)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade600, Colors.orange.shade700],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade600.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_photo_alternate, size: 18),
                    label: Text(l10n.uploadDrawing),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onUpload,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (drawings.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: context.emptyStateBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.borderColor,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.orange.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noDrawings,
                    style: TextStyle(
                      color: context.onSurfaceMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload panel wiring diagram to see related parameters',
                    style: context.bodyStyle?.copyWith(color: context.onSurfaceSubtle, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: drawings.length,
              itemBuilder: (context, index) {
                final drawing = drawings[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: context.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.borderColor,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.onSurface.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade100,
                            Colors.orange.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _getIconForFileType(drawing.fileType),
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      drawing.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 12, color: context.onSurfaceSubtle),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(drawing.uploadedAt),
                            style: TextStyle(
                                fontSize: 11, color: context.onSurfaceMuted),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: context.infoBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.visibility,
                                color: context.infoColor, size: 20),
                            tooltip: 'View',
                            onPressed: () => onOpen(drawing),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: context.errorBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Colors.red.shade700, size: 20),
                            tooltip: 'Delete',
                            onPressed: () => _confirmDelete(context, drawing),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (drawings.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade50,
                    Colors.orange.shade100.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Based on your drawings, relevant parameters will be highlighted automatically.',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconForFileType(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'dwg':
      case 'dxf':
        return Icons.architecture;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _confirmDelete(BuildContext context, VfdDrawing drawing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Drawing'),
        content: Text('Are you sure you want to delete "${drawing.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: context.errorColor),
            onPressed: () {
              Navigator.pop(ctx);
              onDelete(drawing);
            },
            child: Text('Delete', style: TextStyle(color: context.onPrimaryBg)),
          ),
        ],
      ),
    );
  }
}
