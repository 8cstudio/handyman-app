import 'package:my_bloc_app/data/mock/mock_data_store.dart';
import 'package:my_bloc_app/domain/entities/theme/theme_config_entity.dart';
import 'package:my_bloc_app/domain/repository_interfaces/theme_config_repository.dart';

class ThemeConfigRepositoryMockImpl implements ThemeConfigRepository {
  final MockDataStore _store = MockDataStore.instance;

  @override
  Future<ThemeConfigEntity> fetchThemeConfig() async {
    _store.seed();
    return _store.themeConfig;
  }

  @override
  void subscribeToChanges(void Function(ThemeConfigEntity) onUpdate) {
    // No live updates in mock mode.
  }
}
