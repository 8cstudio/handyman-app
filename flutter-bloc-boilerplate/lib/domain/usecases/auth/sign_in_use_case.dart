import 'package:my_bloc_app/core/usecase/usecase.dart';
import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:my_bloc_app/domain/params/auth/sign_in_params.dart';
import 'package:my_bloc_app/domain/repository_interfaces/auth_repository.dart';

class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  @override
  Future<UserEntity> call(SignInParams params) {
    return _repository.signIn(params);
  }
}
