import 'package:my_bloc_app/core/usecase/usecase.dart';
import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:my_bloc_app/domain/params/auth/sign_up_params.dart';
import 'package:my_bloc_app/domain/repository_interfaces/auth_repository.dart';

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  @override
  Future<UserEntity> call(SignUpParams params) {
    return _repository.signUp(params);
  }
}
