import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class Responsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static DeviceType getDeviceType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < desktopBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  // Responsive padding
  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value<double>(
        context,
        mobile: 16,
        tablet: 24,
        desktop: 32,
      ),
      vertical: value<double>(
        context,
        mobile: 16,
        tablet: 20,
        desktop: 24,
      ),
    );
  }

  // Content max width for centered layouts
  static double contentMaxWidth(BuildContext context) {
    return value<double>(
      context,
      mobile: double.infinity,
      tablet: 600,
      desktop: 800,
    );
  }

  // Grid columns for list views
  static int gridColumns(BuildContext context) {
    return value<int>(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
  }
}

// Responsive Widget Builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (Responsive.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

// Responsive Layout with optional sidebar
class ResponsiveLayout extends StatelessWidget {
  final Widget body;
  final Widget? sidebar;
  final Widget? appBar;

  const ResponsiveLayout({
    super.key,
    required this.body,
    this.sidebar,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context) && sidebar != null) {
      return Row(
        children: [
          SizedBox(
            width: 280,
            child: sidebar!,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      );
    }
    return body;
  }
}

// Centered content wrapper for web/desktop
class CenteredContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const CenteredContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.contentMaxWidth(context),
        ),
        padding: padding ?? Responsive.padding(context),
        child: child,
      ),
    );
  }
}