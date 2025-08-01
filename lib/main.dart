import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spinza/core/theme/app_theme.dart';
import 'package:spinza/data/repositories/auth_repository.dart';
import 'package:spinza/data/repositories/order_repository.dart';
import 'package:spinza/data/repositories/product_repository.dart';
import 'package:spinza/data/repositories/admin_order_repository.dart'; // Import new repo
import 'package:spinza/presentation/bloc/auth/auth_bloc.dart';
import 'package:spinza/presentation/bloc/order/order_bloc.dart';
import 'package:spinza/presentation/bloc/product/product_bloc.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_bloc.dart'; // Import new BLoC
import 'package:spinza/presentation/screens/auth_wrapper.dart';
import 'package:spinza/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => ProductRepository()),
        RepositoryProvider(create: (context) => OrderRepository()),
        // --- ADD THE NEW REPO ---
        RepositoryProvider(create: (context) => AdminOrderRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc(authRepository: context.read<AuthRepository>())),
          BlocProvider(
            create: (context) => ProductBloc(productRepository: context.read<ProductRepository>()),
          ),
          BlocProvider(
            create: (context) => OrderBloc(orderRepository: context.read<OrderRepository>()),
          ),
          // --- ADD THE NEW BLOC ---
          BlocProvider(
            create: (context) => AdminOrdersBloc(
              adminOrderRepository: context.read<AdminOrderRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Spinza',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}