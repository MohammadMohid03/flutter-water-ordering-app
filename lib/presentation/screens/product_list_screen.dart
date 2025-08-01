import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/core/utils/app_strings.dart';
import 'package:spinza/presentation/bloc/auth/auth_bloc.dart';
import 'package:spinza/presentation/bloc/auth/auth_event.dart';
import 'package:spinza/presentation/bloc/product/product_bloc.dart';
import 'package:spinza/presentation/bloc/product/product_event.dart';
import 'package:spinza/presentation/bloc/product/product_state.dart';
import 'package:spinza/presentation/widgets/product_card.dart';
import 'package:spinza/presentation/widgets/background_container.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(FetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(AppStrings.products, style: TextStyle(color: Colors.white,fontSize: 22,
            fontWeight: FontWeight.bold,)),
          backgroundColor: Colors.blue,
          elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                    TextButton(
                      child: const Text('Logout'),
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- Layer 1: The Watermark ---
          Center(
            child: Opacity(
              opacity: 0.08, // Keep your desired opacity
              child: ColorFiltered( // <--- WRAP Image.asset WITH ColorFiltered
                colorFilter: ColorFilter.mode(
                  Color(0xFF0072BC), // <--- YOUR DESIRED BLUE COLOR (adjust opacity if needed)
                  BlendMode.srcIn,     // This blend mode will tint the non-transparent parts of your image
                ),
                child: Image.asset(
                  'assets/images/watermark.png',
                  width: MediaQuery.of(context).size.width * 0.7,
                  // You might not need to set the color property on Image.asset directly
                  // if ColorFiltered is handling it, unless your image has multiple colors
                  // and you only want to affect specific parts (which is more complex).
                ),
              ),
            ),
          ),
          // --- Layer 2: The Product List ---
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ProductLoaded) {
                if (state.products.isEmpty) {
                  return const Center(child: Text('No products are available at the moment.'));
                }
                return ListView.builder(
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: state.products[index]);
                  },
                );
              }
              if (state is ProductError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}