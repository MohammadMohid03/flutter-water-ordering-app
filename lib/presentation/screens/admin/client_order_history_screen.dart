import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_state.dart';

class ClientOrderHistoryScreen extends StatelessWidget {
  final ClientOrderSummary clientSummary;

  const ClientOrderHistoryScreen({super.key, required this.clientSummary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${clientSummary.clientName}\'s Orders'),
      ),
      body: ListView.builder(
        itemCount: clientSummary.orders.length,
        itemBuilder: (context, index) {
          final order = clientSummary.orders[index];
          final orderData = order.data() as Map<String, dynamic>;
          final DateTime orderDateTime = (orderData['orderDate'] as Timestamp).toDate();
          final String formattedDate = DateFormat('MMM d, yyyy – hh:mm a').format(orderDateTime);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderData['productName'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('Quantity: ${orderData['quantity']}'),
                  Text('Total Price: PKR ${orderData['totalPrice'].toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}