import 'package:my_bloc_app/core/firebase/push_notification_service.dart';
import 'package:my_bloc_app/data/data_sources/local/auth_local_data_source.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/auth/auth_api.dart';
import 'package:my_bloc_app/data/local/local_cache_store.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:my_bloc_app/domain/params/auth/sign_in_params.dart';
import 'package:my_bloc_app/domain/params/auth/sign_up_params.dart';
import 'package:my_bloc_app/domain/repository_interfaces/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthApi authApi,
    required AuthLocalDataSource localDataSource,
  })  : _authApi = authApi,
        _localDataSource = localDataSource;

  @override
  Future<UserEntity> signIn(SignInParams params) async {
    final user = await _authApi.signIn(params);
    await _localDataSource.saveUser(user);
    await PushNotificationService.instance.syncTokenAfterAuth();
    return user;
  }

  @override
  Future<UserEntity> signUp(SignUpParams params) async {
    final user = await _authApi.signUp(params);
    await _localDataSource.saveUser(user);
    await PushNotificationService.instance.syncTokenAfterAuth();
    return user;
  }

  @override
  Future<void> signOut() async {
    try {
      await PushNotificationService.instance.unregisterToken();
      await _authApi.signOut();
    } finally {
      await _localDataSource.clear();
      await getIt<LocalCacheStore>().clearAll();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await _authApi.getCurrentUser();
    } catch (_) {
      return _localDataSource.getUser();
    }
  }

  @override
  Future<void> forgotPassword(String email, {String? redirectTo}) {
    return _authApi.forgotPassword(email, redirectTo: redirectTo);
  }
}
