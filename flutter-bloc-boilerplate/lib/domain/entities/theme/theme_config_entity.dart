import 'package:equatable/equatable.dart';

class ThemeConfigEntity extends Equatable {
  final String primary;
  final String secondary;
  final Map<String, String> light;
  final Map<String, String> dark;
  final String platformName;

  const ThemeConfigEntity({
    required this.primary,
    required this.secondary,
    required this.light,
    required this.dark,
    this.platformName = 'Handyman SaaS',
  });

  factory ThemeConfigEntity.defaults() => const ThemeConfigEntity(
        primary: '#2563EB',
        secondary: '#64748B',
        platformName: 'Handyman SaaS',
        light: {
          'scaffoldBackground': '#F8FAFC',
          'surface': '#FFFFFF',
          'textPrimary': '#0F172A',
          'textSecondary': '#64748B',
          'error': '#EF4444',
          'success': '#22C55E',
          'drawerBackground': '#FFFFFF',
        },
        dark: {
          'scaffoldBackground': '#0F172A',
          'surface': '#1E293B',
          'textPrimary': '#F8FAFC',
          'textSecondary': '#94A3B8',
          'error': '#F87171',
          'success': '#4ADE80',
          'drawerBackground': '#1E293B',
        },
      );

  factory ThemeConfigEntity.fromJson(Map<String, dynamic> json, {String? platformName}) {
    final defaults = ThemeConfigEntity.defaults();
    final theme = json['theme_config'] as Map<String, dynamic>? ?? json;

    Map<String, String> mergeColors(Map<String, dynamic>? source, Map<String, String> fallback) {
      if (source == null || source.isEmpty) return fallback;
      return {
        for (final entry in fallback.entries)
          entry.key: source[entry.key]?.toString() ?? entry.value,
      };
    }

    return ThemeConfigEntity(
      primary: theme['primary'] as String? ?? defaults.primary,
      secondary: theme['secondary'] as String? ?? defaults.secondary,
      platformName: platformName ?? json['platform_name'] as String? ?? defaults.platformName,
      light: mergeColors(theme['light'] as Map<String, dynamic>?, defaults.light),
      dark: mergeColors(theme['dark'] as Map<String, dynamic>?, defaults.dark),
    );
  }

  @override
  List<Object?> get props => [primary, secondary, light, dark, platformName];
}
