import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInWithGoogle>(_onSignInWithGoogle);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthInitial());
  }

  Future<void> _onSignInWithGoogle(SignInWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.signInWithGoogle();
      // 👉 Add this log to confirm emission
      print("✅ Auth Success: ${result.displayName}, Token: ${result.accessToken}");


      emit(AuthSuccess(accessToken: result.accessToken, displayName: result.displayName));
      // 👉 Add this log to confirm emission
      print("✅ Auth Success: ${result.displayName}, Token: ${result.accessToken}");


    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
