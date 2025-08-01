import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/presentation/bloc/auth/auth_bloc.dart';
import 'package:spinza/presentation/bloc/auth/auth_state.dart';
import 'package:spinza/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:spinza/presentation/screens/product_list_screen.dart';

class RoleDispatcherScreen extends StatelessWidget {
  const RoleDispatcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          if (state.role == 'admin') {
            return const AdminDashboardScreen();
          } else if (state.role == 'client') {
            return const ProductListScreen();
          }
        }
        // While role is being fetched or if something goes wrong, show a loader
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}