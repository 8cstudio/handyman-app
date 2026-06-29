import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/domain/usecases/theme/get_theme_mode_use_case.dart';
import 'package:my_bloc_app/domain/usecases/theme/set_theme_mode_use_case.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final GetThemeModeUseCase _getThemeModeUseCase;
  final SetThemeModeUseCase _setThemeModeUseCase;

  ThemeCubit({
    required GetThemeModeUseCase getThemeModeUseCase,
    required SetThemeModeUseCase setThemeModeUseCase,
  })  : _getThemeModeUseCase = getThemeModeUseCase,
        _setThemeModeUseCase = setThemeModeUseCase,
        super(ThemeMode.light);

  Future<void> loadSavedTheme() async {
    emit(await _getThemeModeUseCase());
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _setThemeModeUseCase(mode);
    emit(mode);
  }
}
