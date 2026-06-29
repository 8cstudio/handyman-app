import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_bloc_app/constants/app_colors.dart';
import 'package:my_bloc_app/constants/app_theme_extension.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_style.dart';

class AppTheme {
  static ThemeData buildLight(AppThemeExtension extension, Color primaryColor) =>
      _buildTheme(
        brightness: Brightness.light,
        extension: extension,
        primaryColor: primaryColor,
      );

  static ThemeData buildDark(AppThemeExtension extension, Color primaryColor) =>
      _buildTheme(
        brightness: Brightness.dark,
        extension: extension,
        primaryColor: primaryColor,
      );

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        extension: AppThemeExtension.light,
        primaryColor: AppColors.primary,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        extension: AppThemeExtension.dark,
        primaryColor: AppColors.primary,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppThemeExtension extension,
    required Color primaryColor,
  }) {
    final isLight = brightness == Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      surface: extension.surface,
      error: extension.error,
    ).copyWith(
      primary: primaryColor,
      onPrimary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      extensions: [extension],
      textTheme: isLight
          ? GoogleFonts.interTextTheme()
          : GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: extension.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: extension.textPrimary),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: extension.drawerBackground.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: extension.textPrimary,
        textColor: extension.textPrimary,
      ),
      dividerTheme: DividerThemeData(
        color: extension.textSecondary.withValues(alpha: 0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? Colors.white.withValues(alpha: 0.52)
            : Colors.white.withValues(alpha: 0.08),
        labelStyle: TextStyle(color: extension.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: isLight
                ? Colors.white.withValues(alpha: 0.72)
                : Colors.white.withValues(alpha: 0.16),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: isLight
                ? Colors.white.withValues(alpha: 0.72)
                : Colors.white.withValues(alpha: 0.16),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: primaryColor.withValues(alpha: 0.65),
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor.withValues(alpha: 0.92),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shadowColor: primaryColor.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: extension.textPrimary,
          minimumSize: const Size.fromHeight(52),
          backgroundColor: isLight
              ? Colors.white.withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          side: BorderSide(
            color: isLight
                ? Colors.white.withValues(alpha: 0.72)
                : Colors.white.withValues(alpha: 0.18),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight
            ? Colors.white.withValues(alpha: 0.42)
            : Colors.white.withValues(alpha: 0.08),
        selectedColor: primaryColor.withValues(alpha: 0.22),
        side: BorderSide(
          color: isLight
              ? Colors.white.withValues(alpha: 0.72)
              : Colors.white.withValues(alpha: 0.16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: TextStyle(color: extension.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: primaryColor.withValues(alpha: 0.18),
        elevation: 0,
        height: 68,
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorColor: primaryColor,
        labelColor: extension.textPrimary,
        unselectedLabelColor: extension.textSecondary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassStyle.radiusMd),
        ),
      ),
    );
  }
}
