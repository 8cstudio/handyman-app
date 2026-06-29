import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/core/dio/exception/api_exception.dart';
import 'package:my_bloc_app/core/firebase/push_notification_service.dart';
import 'package:my_bloc_app/domain/usecases/auth/get_current_user_use_case.dart';
import 'package:my_bloc_app/domain/usecases/auth/sign_in_use_case.dart';
import 'package:my_bloc_app/domain/usecases/auth/sign_out_use_case.dart';
import 'package:my_bloc_app/domain/usecases/auth/sign_up_use_case.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_event.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthReset>(_onAuthReset);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user));
        await PushNotificationService.instance.syncTokenAfterAuth();
        PushNotificationService.instance.handlePendingNotification();
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signInUseCase(event.params);
      emit(AuthAuthenticated(user));
      PushNotificationService.instance.handlePendingNotification();
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signUpUseCase(event.params);
      emit(AuthAuthenticated(user));
      PushNotificationService.instance.handlePendingNotification();
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _signOutUseCase();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void _onAuthReset(AuthReset event, Emitter<AuthState> emit) {
    if (state is AuthAuthenticated) {
      emit(AuthAuthenticated((state as AuthAuthenticated).user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
