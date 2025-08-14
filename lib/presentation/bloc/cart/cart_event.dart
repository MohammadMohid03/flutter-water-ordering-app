import 'package:equatable/equatable.dart';
import 'package:spinza/data/models/cart_item_model.dart';
import 'package:spinza/data/models/product_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object> get props => [];
}

class CartItemAdded extends CartEvent {
  final Product product;
  const CartItemAdded(this.product);
  @override
  List<Object> get props => [product];
}

class CartItemRemoved extends CartEvent {
  final CartItem cartItem;
  const CartItemRemoved(this.cartItem);
  @override
  List<Object> get props => [cartItem];
}

class CartItemQuantityIncreased extends CartEvent {
  final CartItem cartItem;
  const CartItemQuantityIncreased(this.cartItem);
  @override
  List<Object> get props => [cartItem];
}

class CartItemQuantityDecreased extends CartEvent {
  final CartItem cartItem;
  const CartItemQuantityDecreased(this.cartItem);
  @override
  List<Object> get props => [cartItem];
}

// Event to clear the cart after a successful order
class CartCleared extends CartEvent {}