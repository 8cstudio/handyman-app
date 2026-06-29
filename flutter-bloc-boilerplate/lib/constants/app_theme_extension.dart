import 'package:flutter/material.dart';
import 'package:my_bloc_app/constants/app_colors.dart';

/// Semantic app colors that adapt to light/dark mode.
/// Access anywhere via `context.appTheme` (see [AppThemeContext]).
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color scaffoldBackground;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;
  final Color success;
  final Color drawerBackground;

  const AppThemeExtension({
    required this.scaffoldBackground,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.success,
    required this.drawerBackground,
  });

  static const light = AppThemeExtension(
    scaffoldBackground: AppColors.background,
    surface: AppColors.surface,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    error: AppColors.error,
    success: AppColors.success,
    drawerBackground: AppColors.surface,
  );

  static const dark = AppThemeExtension(
    scaffoldBackground: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    error: Color(0xFFF87171),
    success: Color(0xFF4ADE80),
    drawerBackground: Color(0xFF1E293B),
  );

  @override
  AppThemeExtension copyWith({
    Color? scaffoldBackground,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? error,
    Color? success,
    Color? drawerBackground,
  }) {
    return AppThemeExtension(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      error: error ?? this.error,
      success: success ?? this.success,
      drawerBackground: drawerBackground ?? this.drawerBackground,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      scaffoldBackground:
          Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      drawerBackground:
          Color.lerp(drawerBackground, other.drawerBackground, t)!,
    );
  }
}
