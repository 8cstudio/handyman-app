import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/constants/app_theme_extension.dart';
import 'package:my_bloc_app/domain/entities/theme/theme_config_entity.dart';
import 'package:my_bloc_app/domain/repository_interfaces/theme_config_repository.dart';

class ThemeConfigCubit extends Cubit<ThemeConfigEntity> {
  final ThemeConfigRepository _repository;

  ThemeConfigCubit({required ThemeConfigRepository repository})
      : _repository = repository,
        super(ThemeConfigEntity.defaults());

  Future<void> loadThemeConfig() async {
    final config = await _repository.fetchThemeConfig();
    emit(config);
    _repository.subscribeToChanges((updated) => emit(updated));
  }

  AppThemeExtension lightExtension() => _buildExtension(state.light);

  AppThemeExtension darkExtension() => _buildExtension(state.dark);

  Color primaryColor() => _colorFromHex(state.primary);

  AppThemeExtension _buildExtension(Map<String, String> colors) {
    final defaults = ThemeConfigEntity.defaults();
    final fallback = defaults.light;
    return AppThemeExtension(
      scaffoldBackground: _colorFromHex(colors['scaffoldBackground'] ?? fallback['scaffoldBackground']!),
      surface: _colorFromHex(colors['surface'] ?? fallback['surface']!),
      textPrimary: _colorFromHex(colors['textPrimary'] ?? fallback['textPrimary']!),
      textSecondary: _colorFromHex(colors['textSecondary'] ?? fallback['textSecondary']!),
      error: _colorFromHex(colors['error'] ?? fallback['error']!),
      success: _colorFromHex(colors['success'] ?? fallback['success']!),
      drawerBackground: _colorFromHex(colors['drawerBackground'] ?? fallback['drawerBackground']!),
    );
  }

  Color _colorFromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
