import 'package:equatable/equatable.dart';
import 'package:spinza/data/models/cart_item_model.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  // Helper getters to make UI code cleaner
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  @override
  List<Object> get props => [items];
}