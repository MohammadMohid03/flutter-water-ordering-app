import 'package:equatable/equatable.dart';
import 'package:spinza/data/models/product_model.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  // A helper method to create a new instance with an updated quantity
  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}