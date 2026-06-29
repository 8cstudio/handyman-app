import 'package:flutter/material.dart';
import 'package:my_bloc_app/core/usecase/usecase.dart';
import 'package:my_bloc_app/domain/repository_interfaces/theme_repository.dart';

class GetThemeModeUseCase implements UseCaseNoParams<ThemeMode> {
  final ThemeRepository _repository;

  GetThemeModeUseCase(this._repository);

  @override
  Future<ThemeMode> call() => _repository.getThemeMode();
}
