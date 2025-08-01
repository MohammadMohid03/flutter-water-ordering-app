import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import User

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

// Event to notify the BLoC that the auth status has changed
class AuthStatusChanged extends AuthEvent {
  final User? user; // Now sends the full User object
  const AuthStatusChanged(this.user);
  @override
  List<Object?> get props => [user];
}

// ... other events remain the same ...
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
}
class AuthSignupRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthSignupRequested({required this.name, required this.email, required this.password});
}
class AuthLogoutRequested extends AuthEvent {}