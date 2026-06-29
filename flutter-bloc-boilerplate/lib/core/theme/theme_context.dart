import 'package:flutter/material.dart';
import 'package:my_bloc_app/constants/app_theme_extension.dart';

/// Convenient theme access for all screens — prefer this over hardcoded colors.
extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  AppThemeExtension get appTheme =>
      theme.extension<AppThemeExtension>() ?? AppThemeExtension.light;

  bool get isDarkMode => theme.brightness == Brightness.dark;
}
