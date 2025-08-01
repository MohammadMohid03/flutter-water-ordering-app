import 'package:equatable/equatable.dart';
import 'package:spinza/data/models/product_model.dart';

class Order extends Equatable {
  final Product product;
  final int quantity;
  final double totalPrice;

  const Order({
    required this.product,
    required this.quantity,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [product, quantity, totalPrice];
}