import 'package:my_bloc_app/domain/entities/theme/theme_config_entity.dart';

abstract class ThemeConfigRepository {
  Future<ThemeConfigEntity> fetchThemeConfig();
  void subscribeToChanges(void Function(ThemeConfigEntity) onUpdate);
}
