import 'package:my_bloc_app/core/usecase/usecase.dart';
import 'package:my_bloc_app/domain/repository_interfaces/auth_repository.dart';

class SignOutUseCase implements UseCaseNoParams<void> {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  @override
  Future<void> call() {
    return _repository.signOut();
  }
}
