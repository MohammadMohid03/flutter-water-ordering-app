import 'package:flutter/material.dart';
import 'package:spinza/core/utils/app_strings.dart';
import 'package:spinza/data/models/order_model.dart';
import 'package:spinza/presentation/widgets/custom_button.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;
  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.orderConfirmation),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
            const SizedBox(height: 24),
            Text(
              AppStrings.orderPlacedSuccessfully,
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order Summary", style: textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Text("Product: ${order.product.name}", style: textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text("Quantity: ${order.quantity}", style: textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text("Total: PKR ${order.totalPrice.toStringAsFixed(2)}", style: textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const Spacer(),
            CustomButton(
              text: AppStrings.backToHome,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}