import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/data/repositories/auth_repository.dart';
import 'package:spinza/presentation/bloc/auth/auth_event.dart';
import 'package:spinza/presentation/bloc/auth/auth_state.dart';
import 'package:spinza/data/repositories/auth_failure.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<User?> _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    // Listen to the user stream from the repository
    _userSubscription = _authRepository.user.listen(
          (user) => add(AuthStatusChanged(user)),
    );

    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) async {
    if (event.user != null) {
      final role = await _authRepository.getUserRole(event.user!.uid);
      if (role != null) {
        emit(AuthState.authenticated(user: event.user!, role: role));
      } else {
        emit(const AuthState.failure("Could not verify user role."));
        await _authRepository.logout();
      }
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.login(email: event.email, password: event.password);
    } on LoginWithEmailAndPasswordFailure catch (e) {
      // Now we emit the user-friendly message from our custom exception
      emit(AuthState.failure(e.message));
    } catch (_) {
      // A fallback for any other unexpected errors
      emit(const AuthState.failure('An unknown error occurred.'));
    }
  }

  Future<void> _onSignupRequested(
      AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signup(
          name: event.name, email: event.email, password: event.password);
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      // Now we emit the user-friendly message from our custom exception
      emit(AuthState.failure(e.message));
    } catch (_) {
      // A fallback for any other unexpected errors
      emit(const AuthState.failure('An unknown error occurred.'));
    }
  }

  void _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) {
    _authRepository.logout();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}