import 'package:my_bloc_app/core/usecase/usecase.dart';
import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:my_bloc_app/domain/repository_interfaces/auth_repository.dart';

class GetCurrentUserUseCase implements UseCaseNoParams<UserEntity?> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<UserEntity?> call() {
    return _repository.getCurrentUser();
  }
}
