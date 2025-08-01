import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? role; // <-- Role property
  final String? errorMessage;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user,
    this.role,
    this.errorMessage,
  });

  const AuthState.unknown() : this._();
  const AuthState.loading() : this._(status: AuthStatus.loading);

  // Authenticated state now requires a role
  const AuthState.authenticated({required User user, required String role})
      : this._(status: AuthStatus.authenticated, user: user, role: role);

  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);
  const AuthState.failure(String message)
      : this._(status: AuthStatus.failure, errorMessage: message);

  @override
  List<Object?> get props => [status, user, role, errorMessage];
}