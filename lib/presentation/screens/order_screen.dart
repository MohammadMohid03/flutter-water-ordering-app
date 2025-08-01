import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/core/utils/app_strings.dart';
import 'package:spinza/data/models/order_model.dart';
import 'package:spinza/data/models/product_model.dart';
import 'package:spinza/presentation/bloc/order/order_bloc.dart';
import 'package:spinza/presentation/bloc/order/order_event.dart';
import 'package:spinza/presentation/bloc/order/order_state.dart';
import 'package:spinza/presentation/screens/order_confirmation_screen.dart';
import 'package:spinza/presentation/widgets/custom_button.dart';

class OrderScreen extends StatefulWidget {
  final Product product;
  const OrderScreen({super.key, required this.product});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _quantityController = TextEditingController(text: '1');
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.product.price;
    _quantityController.addListener(_updateTotalPrice);
  }

  void _updateTotalPrice() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _totalPrice = widget.product.price * quantity;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.confirmOrder),
      ),
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => OrderConfirmationScreen(order: state.order),
              ),
                  (route) => route.isFirst,
            );
          } else if (state is OrderFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.product.name, style: textTheme.headlineSmall),
              const SizedBox(height: 20),
              Text(AppStrings.quantity, style: textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  hintText: AppStrings.quantity,
                ),
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.total, style: textTheme.titleLarge),
                  Text('PKR ${_totalPrice.toStringAsFixed(2)}', style: textTheme.headlineSmall),
                ],
              ),
              const Spacer(),
              BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  return CustomButton(
                    text: AppStrings.confirmOrder,
                    isLoading: state is OrderInProgress,
                    onPressed: () {
                      final quantity = int.tryParse(_quantityController.text) ?? 0;
                      if (quantity > 0) {
                        final order = Order(
                          product: widget.product,
                          quantity: quantity,
                          totalPrice: _totalPrice,
                        );
                        context.read<OrderBloc>().add(CreateOrder(order));
                      }
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}