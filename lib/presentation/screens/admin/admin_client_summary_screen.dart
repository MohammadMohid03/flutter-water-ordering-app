import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_bloc.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_event.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_state.dart';
import 'package:spinza/presentation/screens/admin/client_order_history_screen.dart';

class AdminClientSummaryScreen extends StatelessWidget {
  const AdminClientSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AdminOrdersBloc>().add(FetchAllOrders());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Orders'),
      ),
      body: BlocBuilder<AdminOrdersBloc, AdminOrdersState>(
        builder: (context, state) {
          if (state is AdminOrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminOrdersError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is AdminOrdersLoaded) {
            if (state.clientSummaries.isEmpty) {
              return const Center(child: Text('No client orders found yet.'));
            }
            return ListView.builder(
              itemCount: state.clientSummaries.length,
              itemBuilder: (context, index) {
                final summary = state.clientSummaries[index];
                final String formattedDate =
                DateFormat('MMM d, yyyy').format(summary.lastOrderDate.toDate());

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(summary.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Total Orders: ${summary.totalOrders}'),
                        Text('Total Spent: PKR ${summary.totalSpent.toStringAsFixed(2)}'),
                        Text('Last Order: $formattedDate'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ClientOrderHistoryScreen(clientSummary: summary),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Click the refresh button to load orders.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<AdminOrdersBloc>().add(FetchAllOrders()),
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Orders',
      ),
    );
  }
}