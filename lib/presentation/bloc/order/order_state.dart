import 'package:equatable/equatable.dart';
import 'package:spinza/data/models/cart_item_model.dart'; // Import CartItem

// The Order class from your model is no longer needed here,
// as the state won't hold it anymore.

abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderInProgress extends OrderState {}

// --- THIS IS THE FIX ---
// The OrderSuccess state is now just a signal, it doesn't hold any data.
class OrderSuccess extends OrderState {
  final List<CartItem> orderedItems;
  final double totalPrice;

  const OrderSuccess({required this.orderedItems, required this.totalPrice});

  @override
  List<Object> get props => [orderedItems, totalPrice];
}

class OrderFailure extends OrderState {
  final String message;
  const OrderFailure(this.message);
  @override
  List<Object> get props => [message];
}