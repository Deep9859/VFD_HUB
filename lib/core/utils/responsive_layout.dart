import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }
enum ScreenSize { small, medium, large, extraLarge }

class ResponsiveLayout {
  // Device Type Detection
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 900;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static DeviceType getDeviceType(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    if (shortestSide >= 900) return DeviceType.desktop;
    if (shortestSide >= 600) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return ScreenSize.extraLarge;
    if (width >= 900) return ScreenSize.large;
    if (width >= 600) return ScreenSize.medium;
    return ScreenSize.small;
  }

  // Split Screen Detection
  static bool isSplitScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.width / size.height;
    // Detect unusual aspect ratios that indicate split screen
    return (aspectRatio < 0.5 || aspectRatio > 2.5) && isTablet(context);
  }

  // Responsive Sizing
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return baseSize * 1.4;
      case DeviceType.tablet:
        return baseSize * 1.2;
      case DeviceType.mobile:
        return baseSize;
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return const EdgeInsets.all(32);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
    }
  }

  static double getResponsiveCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isDesktop(context)) return width * 0.3;
    if (isTablet(context)) return width * 0.45;
    return width * 0.9;
  }

  // Grid Layout
  static int getCrossAxisCount(BuildContext context) {
    if (isSplitScreen(context)) return 1;
    if (isDesktop(context)) return 4;
    if (isTablet(context) && isLandscape(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  static double getGridSpacing(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return 24;
      case DeviceType.tablet:
        return 16;
      case DeviceType.mobile:
        return 12;
    }
  }

  // Tablet Specific
  static bool shouldUseTwoPane(BuildContext context) {
    return isTablet(context) && isLandscape(context) && !isSplitScreen(context);
  }

  static double getMasterPaneWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.35;
  }

  static double getDetailPaneWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.65;
  }

  // Adaptive Values
  static T getAdaptiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, bool) builder;
  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveLayout.isTablet(context));
  }
}
