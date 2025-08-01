import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/presentation/bloc/product/product_bloc.dart';
import 'package:spinza/presentation/bloc/product/product_event.dart';
import 'package:spinza/presentation/bloc/product/product_state.dart';
import 'package:spinza/presentation/screens/admin/admin_product_form_screen.dart';

class AdminProductListScreen extends StatelessWidget {
  const AdminProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure products are fetched when entering the screen
    context.read<ProductBloc>().add(FetchProducts());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductLoaded) {
            if (state.products.isEmpty) {
              return const Center(child: Text('No products found. Add one to get started!'));
            }
            return ListView.builder(
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Image.asset(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('PKR ${product.price.toStringAsFixed(2)}'),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          // Navigate to form screen in "Edit" mode
                          builder: (_) => AdminProductFormScreen(product: product),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          if (state is ProductError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              // Navigate to form screen in "Add" mode (product is null)
              builder: (_) => const AdminProductFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }
}