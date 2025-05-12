import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// A utility class that provides responsive sizing and layout helpers for web
class WebResponsive {
  /// Screen width breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1800;

  /// Returns true if the current screen size is for a mobile device
  static bool isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return size < mobileBreakpoint;
  }

  /// Returns true if the current screen size is for a tablet
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return size >= mobileBreakpoint && size < tabletBreakpoint;
  }

  /// Returns true if the current screen size is for a desktop
  static bool isDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return size >= tabletBreakpoint && size < desktopBreakpoint;
  }

  /// Returns true if the current screen size is for a large desktop
  static bool isLargeDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return size >= desktopBreakpoint;
  }

  /// Returns a value based on the current screen size
  static T getValueForScreenType<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop(context)) {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    if (isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Returns the appropriate padding based on screen size
  static EdgeInsets getPaddingForScreenType(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: const EdgeInsets.all(16.0),
      tablet: const EdgeInsets.all(24.0),
      desktop: const EdgeInsets.all(32.0),
      largeDesktop: const EdgeInsets.all(48.0),
    );
  }

  /// Returns a responsive width based on screen size percentage
  static double getResponsiveWidth(BuildContext context,
      {double percent = 1.0}) {
    return MediaQuery.of(context).size.width * percent;
  }

  /// Returns a responsive height based on screen size percentage
  static double getResponsiveHeight(BuildContext context,
      {double percent = 1.0}) {
    return MediaQuery.of(context).size.height * percent;
  }

  /// Returns a responsive font size based on screen size
  static double getResponsiveFontSize(BuildContext context,
      {double baseFontSize = 16.0}) {
    final double scaleFactor = getValueForScreenType(
      context: context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
      largeDesktop: 1.3,
    );

    return baseFontSize * scaleFactor;
  }

  /// Returns the number of grid columns based on screen size
  static int getResponsiveGridCount(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );
  }

  /// Returns true if the current device is a web browser
  static bool get isWebPlatform => kIsWeb;

  /// Returns the appropriate max width constraint for content
  static double getMaxContentWidth(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: double.infinity,
      tablet: 700,
      desktop: 900,
      largeDesktop: 1200,
    );
  }

  /// Returns a responsive widget based on screen size
  static Widget responsiveBuilder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? largeDesktop,
  }) {
    if (isLargeDesktop(context)) {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    if (isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}

/// A widget that builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
      BuildContext, bool isMobile, bool isTablet, bool isDesktop) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = WebResponsive.isMobile(context);
    final isTablet = WebResponsive.isTablet(context);
    final isDesktop = WebResponsive.isDesktop(context) ||
        WebResponsive.isLargeDesktop(context);

    return builder(context, isMobile, isTablet, isDesktop);
  }
}
