import 'package:equatable/equatable.dart';

abstract class UseCase<T, P> {
  Future<T> call(P params);
}

abstract class UseCaseNoParams<T> {
  Future<T> call();
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
