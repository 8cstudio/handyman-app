import 'package:my_bloc_app/core/supabase/supabase_service.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/auth/auth_api.dart';
import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:my_bloc_app/domain/entities/user/user_role.dart';
import 'package:my_bloc_app/domain/params/auth/sign_in_params.dart';
import 'package:my_bloc_app/domain/params/auth/sign_up_params.dart';

class AuthApiSupabaseImpl implements AuthApi {
  @override
  Future<UserEntity> signIn(SignInParams params) async {
    final response = await SupabaseService.client.auth.signInWithPassword(
      email: params.email,
      password: params.password,
    );

    if (response.user == null) {
      throw Exception('Sign in failed');
    }

    return _buildUser(response.user!.id, response.session?.accessToken);
  }

  @override
  Future<UserEntity> signUp(SignUpParams params) async {
    if (params.role == UserRole.provider) {
      await SupabaseService.invokeFunction('auth-register-provider', body: {
        'email': params.email,
        'password': params.password,
        'full_name': params.name,
        'phone': params.phone,
        'company_id': params.companyId ?? 'a0000000-0000-4000-8000-000000000001',
        'skills': params.skills ?? [],
        'experience_years': params.experienceYears ?? 0,
      });
    } else {
      await SupabaseService.invokeFunction('auth-register-customer', body: {
        'email': params.email,
        'password': params.password,
        'full_name': params.name,
        'phone': params.phone,
        'company_id': params.companyId ?? 'a0000000-0000-4000-8000-000000000001',
      });
    }

    return signIn(SignInParams(email: params.email, password: params.password));
  }

  @override
  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return null;
    return _buildUser(user.id, SupabaseService.client.auth.currentSession?.accessToken);
  }

  Future<UserEntity> _buildUser(String userId, String? accessToken) async {
    final profile = await SupabaseService.client
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .maybeSingle();

    String? providerStatus;
    if (profile != null && profile['role'] == 'provider') {
      final provider = await SupabaseService.client
          .from('providers')
          .select('status')
          .eq('user_id', userId)
          .maybeSingle();
      providerStatus = provider?['status'] as String?;
    }

    final user = SupabaseService.client.auth.currentUser;

    return UserEntity(
      id: userId,
      name: profile?['full_name'] as String? ?? user?.email ?? '',
      email: user?.email ?? '',
      accessToken: accessToken,
      role: UserRole.fromString(profile?['role'] as String?),
      companyId: profile?['company_id'] as String?,
      phone: profile?['phone'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      providerStatus: providerStatus,
    );
  }

  @override
  Future<void> forgotPassword(String email, {String? redirectTo}) async {
    await SupabaseService.invokeFunction('auth-forgot-password', body: {
      'email': email,
      if (redirectTo != null) 'redirect_to': redirectTo,
    });
  }
}
