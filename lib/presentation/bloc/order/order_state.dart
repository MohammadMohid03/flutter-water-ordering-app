import 'package:equatable/equatable.dart';
import 'package:spinza/data/models/order_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderInProgress extends OrderState {}

class OrderSuccess extends OrderState {
  final Order order;

  const OrderSuccess(this.order);
  @override
  List<Object> get props => [order];
}

class OrderFailure extends OrderState {
  final String message;

  const OrderFailure(this.message);
  @override
  List<Object> get props => [message];
}