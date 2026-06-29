import 'package:flutter/material.dart';
import 'package:my_bloc_app/data/data_sources/local/theme_local_data_source.dart';
import 'package:my_bloc_app/domain/repository_interfaces/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource _localDataSource;

  ThemeRepositoryImpl(this._localDataSource);

  @override
  Future<ThemeMode> getThemeMode() => _localDataSource.getThemeMode();

  @override
  Future<void> setThemeMode(ThemeMode mode) =>
      _localDataSource.saveThemeMode(mode);
}
