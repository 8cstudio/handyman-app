import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:my_bloc_app/domain/params/auth/sign_in_params.dart';
import 'package:my_bloc_app/domain/params/auth/sign_up_params.dart';

abstract class AuthApi {
  Future<UserEntity> signIn(SignInParams params);
  Future<UserEntity> signUp(SignUpParams params);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<void> forgotPassword(String email, {String? redirectTo});
}
