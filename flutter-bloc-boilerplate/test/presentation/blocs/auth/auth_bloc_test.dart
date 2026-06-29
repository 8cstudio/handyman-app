import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:my_bloc_app/domain/params/auth/sign_in_params.dart';
import 'package:my_bloc_app/domain/usecases/auth/get_current_user_use_case.dart';
import 'package:my_bloc_app/domain/usecases/auth/sign_in_use_case.dart';
import 'package:my_bloc_app/domain/usecases/auth/sign_out_use_case.dart';
import 'package:my_bloc_app/domain/usecases/auth/sign_up_use_case.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_event.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_state.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const SignInParams(email: 'fallback@example.com', password: 'password'),
    );
  });

  late AuthBloc authBloc;
  late MockSignInUseCase signInUseCase;
  late MockSignUpUseCase signUpUseCase;
  late MockSignOutUseCase signOutUseCase;
  late MockGetCurrentUserUseCase getCurrentUserUseCase;

  const user = UserEntity(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    accessToken: 'token',
  );

  setUp(() {
    signInUseCase = MockSignInUseCase();
    signUpUseCase = MockSignUpUseCase();
    signOutUseCase = MockSignOutUseCase();
    getCurrentUserUseCase = MockGetCurrentUserUseCase();

    authBloc = AuthBloc(
      signInUseCase: signInUseCase,
      signUpUseCase: signUpUseCase,
      signOutUseCase: signOutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
    );
  });

  tearDown(() => authBloc.close());

  test('initial state is AuthInitial', () {
    expect(authBloc.state, const AuthInitial());
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
    build: () {
      when(() => signInUseCase(any())).thenAnswer((_) async => user);
      return authBloc;
    },
    act: (bloc) => bloc.add(
      const SignInRequested(
        SignInParams(email: 'test@example.com', password: 'password'),
      ),
    ),
    expect: () => [
      const AuthLoading(),
      const AuthAuthenticated(user),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthUnauthenticated] when auth check finds no user',
    build: () {
      when(() => getCurrentUserUseCase()).thenAnswer((_) async => null);
      return authBloc;
    },
    act: (bloc) => bloc.add(const AuthCheckRequested()),
    expect: () => [
      const AuthLoading(),
      const AuthUnauthenticated(),
    ],
  );
}
