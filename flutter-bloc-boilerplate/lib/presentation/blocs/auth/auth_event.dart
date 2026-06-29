import 'package:equatable/equatable.dart';
import 'package:my_bloc_app/domain/params/auth/sign_in_params.dart';
import 'package:my_bloc_app/domain/params/auth/sign_up_params.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class SignInRequested extends AuthEvent {
  final SignInParams params;

  const SignInRequested(this.params);

  @override
  List<Object?> get props => [params];
}

class SignUpRequested extends AuthEvent {
  final SignUpParams params;

  const SignUpRequested(this.params);

  @override
  List<Object?> get props => [params];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class AuthReset extends AuthEvent {
  const AuthReset();
}
