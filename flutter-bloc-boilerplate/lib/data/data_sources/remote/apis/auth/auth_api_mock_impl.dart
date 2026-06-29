import 'package:my_bloc_app/data/mock/mock_data_store.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/auth/auth_api.dart';
import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:my_bloc_app/domain/entities/user/user_role.dart';
import 'package:my_bloc_app/domain/params/auth/sign_in_params.dart';
import 'package:my_bloc_app/domain/params/auth/sign_up_params.dart';

/// Local auth + data stub when [FlavorConfig.useMockAuth] is true.
/// Demo accounts (any password):
/// - customer@demo.com
/// - provider@demo.com (approved)
/// - provider-pending@demo.com (pending approval)
class AuthApiMockImpl implements AuthApi {
  final MockDataStore _store = MockDataStore.instance;

  AuthApiMockImpl() {
    _store.seed();
  }

  @override
  Future<UserEntity> signIn(SignInParams params) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final email = params.email.toLowerCase().trim();

    final existing = _store.userByEmail(email);
    if (existing != null) {
      return existing.copyWith(
        accessToken: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    return UserEntity(
      id: 'mock-${email.hashCode.abs()}',
      name: email.split('@').first,
      email: email,
      role: UserRole.customer,
      accessToken: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<UserEntity> signUp(SignUpParams params) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final email = params.email.toLowerCase().trim();

    final user = UserEntity(
      id: 'mock-${email.hashCode.abs()}',
      name: params.name,
      email: email,
      phone: params.phone,
      role: params.role,
      providerStatus: params.role == UserRole.provider ? 'pending' : null,
      accessToken: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    _store.registerUser(user);
    return user;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  Future<void> forgotPassword(String email, {String? redirectTo}) async {}
}
