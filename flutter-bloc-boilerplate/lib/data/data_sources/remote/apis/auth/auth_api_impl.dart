import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_bloc_app/core/dio/dio_client.dart';
import 'package:my_bloc_app/core/dio/exception/api_exception.dart';
import 'package:my_bloc_app/core/supabase/supabase_service.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/auth/auth_api.dart';
import 'package:my_bloc_app/data/data_sources/remote/constants/network_constants.dart';
import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:my_bloc_app/domain/entities/user/user_role.dart';
import 'package:my_bloc_app/domain/params/auth/sign_in_params.dart';
import 'package:my_bloc_app/domain/params/auth/sign_up_params.dart';

class AuthApiImpl implements AuthApi {
  final DioClient _dioClient;

  AuthApiImpl(this._dioClient);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  @override
  Future<UserEntity> signIn(SignInParams params) async {
    try {
      final response = await _dioClient.post(
        NetworkConstants.signIn,
        data: params.toJson(),
        options: Options(headers: _headers),
      );
      return _parseAuthResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<UserEntity> signUp(SignUpParams params) async {
    if (params.role == UserRole.provider) {
      throw const ApiException(
        message: 'Providers are added by your company. Please sign in instead.',
      );
    }

    try {
      await _dioClient.post(
        NetworkConstants.signUp,
        data: {
          'email': params.email,
          'password': params.password,
          'full_name': params.name,
          'phone': params.phone,
          'company_id': params.companyId,
        },
        options: Options(headers: _headers),
      );

      return signIn(
        SignInParams(email: params.email, password: params.password),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await SupabaseService.client.auth.signOut();
    } catch (_) {
      // Local session cleanup is handled by the repository.
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    try {
      final response = await _dioClient.get(
        NetworkConstants.currentUser,
        options: Options(
          headers: {
            ..._headers,
            'Authorization': 'Bearer ${session.accessToken}',
          },
        ),
      );
      final data = response.data as Map<String, dynamic>;
      final userJson = data['user'] as Map<String, dynamic>? ?? data;
      return UserEntity.fromJson(userJson).copyWith(
        accessToken: session.accessToken,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> forgotPassword(String email, {String? redirectTo}) async {
    try {
      await _dioClient.post(
        NetworkConstants.forgotPassword,
        data: {
          'email': email,
          if (redirectTo != null) 'redirect_to': redirectTo,
        },
        options: Options(headers: _headers),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserEntity> _parseAuthResponse(Map<String, dynamic> data) async {
    final userJson = data['user'] as Map<String, dynamic>? ?? data;
    final accessToken = userJson['access_token'] as String?;
    final refreshToken = userJson['refresh_token'] as String?;

    if (accessToken != null && refreshToken != null) {
      await SupabaseService.client.auth.setSession(
        refreshToken,
        accessToken: accessToken,
      );
    }

    return UserEntity.fromJson(userJson).copyWith(accessToken: accessToken);
  }
}
