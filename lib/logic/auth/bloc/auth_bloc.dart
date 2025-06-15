import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      emit(AuthInitial()); // Add logic to check saved state if needed
    });

    on<SignInWithGooglePressed>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authRepository.signInWithGoogle();
        emit(AuthSuccess(
          accessToken: result.accessToken,
          displayName: result.displayName,
        ));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthInitial()); // You may call signOut from Firebase if needed
    });
  }
}
