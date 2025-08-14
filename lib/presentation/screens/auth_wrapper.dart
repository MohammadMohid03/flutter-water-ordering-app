import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/presentation/bloc/auth/auth_bloc.dart';
import 'package:spinza/presentation/bloc/auth/auth_state.dart';
import 'package:spinza/presentation/screens/auth_screen.dart';
import 'package:spinza/presentation/screens/role_dispatcher_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          // Instead of going straight to products, go to the dispatcher
          return const RoleDispatcherScreen();
        } else {
          // If not logged in, show the login screen
          return AuthScreen();
        }
      },
    );
  }
}