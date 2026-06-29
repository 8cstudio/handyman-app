import 'package:flutter/material.dart';
import 'package:my_bloc_app/core/theme/theme_context.dart';

class GlassStyle {
  static const double radiusSm = 16;
  static const double radiusMd = 22;
  static const double radiusLg = 28;
  static const double radiusXl = 32;

  static const double shellNavBarHeight = 68;
  static const double shellNavBarOuterPadding = 12;

  static Color glassFill(BuildContext context) {
    final isDark = context.isDarkMode;
    return isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.52);
  }

  static Color glassBorder(BuildContext context) {
    final isDark = context.isDarkMode;
    return isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.72);
  }

  static Color glassHighlight(BuildContext context) {
    return Colors.white.withValues(alpha: context.isDarkMode ? 0.06 : 0.35);
  }

  static List<Color> liquidBlobColors(BuildContext context) {
    final primary = context.colors.primary;
    return [
      primary.withValues(alpha: context.isDarkMode ? 0.45 : 0.35),
      const Color(0xFF8B5CF6).withValues(alpha: context.isDarkMode ? 0.32 : 0.22),
      const Color(0xFF06B6D4).withValues(alpha: context.isDarkMode ? 0.28 : 0.18),
      const Color(0xFFEC4899).withValues(alpha: context.isDarkMode ? 0.22 : 0.14),
    ];
  }

  static Color liquidBase(BuildContext context) {
    return context.isDarkMode
        ? const Color(0xFF070B14)
        : const Color(0xFFE8EEF9);
  }

  static double shellTabBottomInset(BuildContext context, {double extra = 16}) {
    return MediaQuery.paddingOf(context).bottom +
        shellNavBarHeight +
        shellNavBarOuterPadding +
        extra;
  }

  static EdgeInsets shellTabPadding(
    BuildContext context, {
    double horizontal = 16,
    double top = 16,
    double extraBottom = 16,
  }) {
    return EdgeInsets.fromLTRB(
      horizontal,
      top,
      horizontal,
      shellTabBottomInset(context, extra: extraBottom),
    );
  }

  static BoxDecoration cardDecoration(
    BuildContext context, {
    double borderRadius = radiusMd,
    bool elevated = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          glassFill(context),
          glassFill(context).withValues(alpha: glassFill(context).a * 0.75),
        ],
      ),
      border: Border.all(color: glassBorder(context), width: 1.2),
      boxShadow: elevated
          ? [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ]
          : null,
    );
  }

  static BoxDecoration panelDecoration(BuildContext context) {
    return BoxDecoration(
      color: glassFill(context),
      border: Border(
        top: BorderSide(color: glassBorder(context)),
      ),
    );
  }

  static InputDecoration inputDecoration(
    BuildContext context, {
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: glassFill(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide(color: glassBorder(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide(
          color: context.colors.primary.withValues(alpha: 0.65),
          width: 1.5,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide(color: glassBorder(context)),
      ),
    );
  }
}
