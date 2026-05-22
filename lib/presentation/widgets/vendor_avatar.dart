import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/vendor_model.dart';

/// Vendor logo widget — network image with fallback to colored initial avatar.
class VendorAvatar extends StatelessWidget {
  final Vendor vendor;
  final double size;

  const VendorAvatar({super.key, required this.vendor, this.size = 36});

  static const Map<String, String> _logoUrls = {
    'delta':
        'https://upload.wikimedia.org/wikipedia/commons/b/b7/Delta_logo.svg',
    'siemens':
        'https://upload.wikimedia.org/wikipedia/commons/5/5f/Siemens-logo.svg',
    'abb':
        'https://upload.wikimedia.org/wikipedia/commons/4/4b/ABB_logo.svg',
    'schneider':
        'https://upload.wikimedia.org/wikipedia/commons/3/3c/Schneider_Electric_logo.svg',
    'hitachi':
        'https://upload.wikimedia.org/wikipedia/commons/f/ff/Hitachi_logo.svg',
    'mitsubishi':
        'https://upload.wikimedia.org/wikipedia/commons/5/5c/Mitsubishi_Electric_logo.svg',
    'yaskawa':
        'https://upload.wikimedia.org/wikipedia/commons/3/3d/YASKAWA_ELETRIC_CORPORATION_logo.svg',
  };

  static const Map<String, Color> _vendorColors = {
    'delta': AppTheme.primary,
    'siemens': AppTheme.primaryLight,
    'abb': AppTheme.primaryDark,
    'schneider': AppTheme.primary,
    'hitachi': AppTheme.primaryLight,
    'mitsubishi': AppTheme.primaryDark,
    'yaskawa': AppTheme.primary,
    'danfoss': AppTheme.primaryLight,
    'allen bradley': AppTheme.primaryDark,
    'toshiba': AppTheme.primary,
    'weg': AppTheme.primaryLight,
    'ls': AppTheme.primaryDark,
    'lenze': AppTheme.primary,
    'omron': AppTheme.primaryLight,
    'inovance': AppTheme.primaryDark,
    'invt': AppTheme.primary,
    'keb': AppTheme.primaryLight,
    'parker': AppTheme.primaryDark,
    'fuji': AppTheme.primary,
    'l&t': AppTheme.primaryLight,
    'nidec': AppTheme.primaryDark,
  };

  /// Public static helper so other widgets can get the vendor color.
  static Color vendorColor(String name) =>
      _vendorColors[name.toLowerCase()] ?? const Color(0xFF616161);

  Color get _color => vendorColor(vendor.name);

  String? get _logoUrl {
    if (vendor.logo.isNotEmpty) return vendor.logo;
    return _logoUrls[vendor.name.toLowerCase()];
  }

  @override
  Widget build(BuildContext context) {
    final url = _logoUrl;
    final color = _color;
    final initial = vendor.name.isNotEmpty
        ? vendor.name[0].toUpperCase()
        : '?';

    if (url != null && url.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.2),
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _InitialAvatar(
              initial: initial,
              color: color,
              size: size,
            ),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return _InitialAvatar(
                initial: initial,
                color: color,
                size: size,
              );
            },
          ),
        ),
      );
    }

    return _InitialAvatar(initial: initial, color: color, size: size);
  }
}

class _InitialAvatar extends StatelessWidget {
  final String initial;
  final Color color;
  final double size;

  const _InitialAvatar({
    required this.initial,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.45,
        ),
      ),
    );
  }
}
