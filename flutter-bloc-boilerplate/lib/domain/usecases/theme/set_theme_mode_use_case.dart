import 'package:flutter/material.dart';
import 'package:my_bloc_app/core/usecase/usecase.dart';
import 'package:my_bloc_app/domain/repository_interfaces/theme_repository.dart';

class SetThemeModeUseCase implements UseCase<void, ThemeMode> {
  final ThemeRepository _repository;

  SetThemeModeUseCase(this._repository);

  @override
  Future<void> call(ThemeMode params) => _repository.setThemeMode(params);
}
