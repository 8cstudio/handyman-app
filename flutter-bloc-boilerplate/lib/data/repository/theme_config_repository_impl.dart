import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_bloc_app/core/supabase/supabase_service.dart';
import 'package:my_bloc_app/domain/entities/theme/theme_config_entity.dart';
import 'package:my_bloc_app/domain/repository_interfaces/theme_config_repository.dart';

class ThemeConfigRepositoryImpl implements ThemeConfigRepository {
  @override
  Future<ThemeConfigEntity> fetchThemeConfig() async {
    final fromSupabase = await _fetchFromSupabase();
    if (fromSupabase != null) return fromSupabase;

    final fromApi = await _fetchFromApi();
    if (fromApi != null) return fromApi;

    return ThemeConfigEntity.defaults();
  }

  Future<ThemeConfigEntity?> _fetchFromSupabase() async {
    try {
      final data = await SupabaseService.client
          .from('platform_settings')
          .select('*')
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      return ThemeConfigEntity.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<ThemeConfigEntity?> _fetchFromApi() async {
    try {
      final data = await SupabaseService.invokeFunction(
        'platform-settings',
        method: 'GET',
      );
      final settings = data['settings'];
      if (settings is! Map<String, dynamic>) return null;
      return ThemeConfigEntity.fromJson(settings);
    } catch (_) {
      return null;
    }
  }

  @override
  void subscribeToChanges(void Function(ThemeConfigEntity) onUpdate) {
    SupabaseService.client
        .channel('platform_settings_flutter')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'platform_settings',
          callback: (payload) async {
            final record = payload.newRecord;
            if (record.isEmpty) return;
            onUpdate(ThemeConfigEntity.fromJson(record));
          },
        )
        .subscribe();
  }
}
