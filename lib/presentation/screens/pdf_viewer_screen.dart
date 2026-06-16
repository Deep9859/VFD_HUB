import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/theme_context.dart';
import '../widgets/app_card.dart';
import '../../data/models/vfd_manual.dart';

class PdfViewerScreen extends StatefulWidget {
  final VfdManual manual;

  const PdfViewerScreen({super.key, required this.manual});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen>
    with SingleTickerProviderStateMixin {
  PDFViewController? _pdfController;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  bool _showControls = true;
  String? _errorMessage;
  late AnimationController _controlsAnim;

  bool get _isUrl =>
      widget.manual.filePath.startsWith('http://') ||
      widget.manual.filePath.startsWith('https://');

  bool get _fileExists =>
      !_isUrl && File(widget.manual.filePath).existsSync();

  @override
  void initState() {
    super.initState();
    _controlsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controlsAnim.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _controlsAnim.forward();
    } else {
      _controlsAnim.reverse();
    }
  }

  Future<void> _goToPage(int page) async {
    if (_pdfController == null) return;
    await _pdfController!.setPage(page);
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.manual.filePath);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  void _copyPath() {
    Clipboard.setData(ClipboardData(text: widget.manual.filePath));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: context.onPrimaryBg, size: 18),
            const SizedBox(width: 8),
            const Text('Link copied to clipboard'),
          ],
        ),
        backgroundColor: context.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.surfaceMuted,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.manual.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.manual.manualType,
              style: TextStyle(
                fontSize: 11,
                color: context.onPrimaryBg.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          if (_isUrl)
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              tooltip: 'Open in browser',
              onPressed: _openInBrowser,
            ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy link',
            onPressed: _copyPath,
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    // URL manual - show open in browser screen
    if (_isUrl) {
      return _buildUrlScreen(isDark);
    }

    // File not found
    if (!_fileExists) {
      return _buildErrorScreen(
        icon: Icons.picture_as_pdf,
        title: 'PDF Not Found',
        message: 'The manual file could not be located on this device.',
        isDark: isDark,
      );
    }

    // Error loading
    if (_errorMessage != null) {
      return _buildErrorScreen(
        icon: Icons.error_outline,
        title: 'Error Loading PDF',
        message: _errorMessage!,
        isDark: isDark,
      );
    }

    // PDF viewer
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        children: [
          PDFView(
            filePath: widget.manual.filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: _currentPage,
            fitPolicy: FitPolicy.BOTH,
            onRender: (pages) => setState(() {
              _totalPages = pages ?? 0;
              _isReady = true;
            }),
            onError: (error) => setState(() => _errorMessage = error.toString()),
            onPageError: (page, error) =>
                setState(() => _errorMessage = 'Page $page: $error'),
            onViewCreated: (controller) =>
                setState(() => _pdfController = controller),
            onPageChanged: (page, total) => setState(() {
              _currentPage = page ?? 0;
              _totalPages = total ?? 0;
            }),
          ),

          // Loading overlay
          if (!_isReady)
            Container(
              color: context.surfaceMuted,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: context.onSurface.withOpacity(0.1),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading PDF...',
                            style: context.bodyStyle?.copyWith(
                              color: context.onSurfaceMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom navigation controls
          if (_isReady && _totalPages > 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _controlsAnim,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Prev button
                      _navButton(
                        icon: Icons.chevron_left,
                        enabled: _currentPage > 0,
                        onTap: () => _goToPage(_currentPage - 1),
                      ),
                      const SizedBox(width: 12),

                      // Page slider
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Page ${_currentPage + 1} of $_totalPages',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16,
                                ),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white30,
                                thumbColor: Colors.white,
                                overlayColor: Colors.white24,
                              ),
                              child: Slider(
                                value: _currentPage.toDouble(),
                                min: 0,
                                max: (_totalPages - 1).toDouble(),
                                onChanged: (val) => _goToPage(val.round()),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),
                      // Next button
                      _navButton(
                        icon: Icons.chevron_right,
                        enabled: _currentPage < _totalPages - 1,
                        onTap: () => _goToPage(_currentPage + 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Page indicator top-right (always visible)
          if (_isReady && _totalPages > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white30,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildUrlScreen(bool isDark) {
    final color = Theme.of(context).primaryColor;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: AppCard(
          icon: Icons.picture_as_pdf,
          title: widget.manual.title,
          subtitle: widget.manual.manualType,
          accentColor: color,
          backgroundColor: context.surfaceCard,
          titleColor: context.onSurface,
          subtitleColor: context.onSurfaceMuted,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                ),
                child: Icon(Icons.picture_as_pdf, size: 64, color: color),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  widget.manual.manualType,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link, size: 16, color: context.onSurfaceSubtle),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.manual.filePath,
                        style: context.captionStyle?.copyWith(
                          color: context.onSurfaceMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in Browser'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: color.withOpacity(0.4),
                  ),
                  onPressed: _openInBrowser,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _copyPath,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen({
    required IconData icon,
    required String title,
    required String message,
    required bool isDark,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.errorBg,
                shape: BoxShape.circle,
                border: Border.all(color: context.tintedBorder(context.errorColor), width: 2),
              ),
              child: Icon(icon, size: 56, color: context.errorColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: context.titleStyle?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.errorBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.tintedBorder(context.errorColor)),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.errorColor, fontSize: 13, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
