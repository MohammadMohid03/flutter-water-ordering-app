import 'package:equatable/equatable.dart';

abstract class AdminOrdersEvent extends Equatable {
  const AdminOrdersEvent();
  @override
  List<Object> get props => [];
}

class FetchAllOrders extends AdminOrdersEvent {}

class UpdateOrderStatus extends AdminOrdersEvent {
  final String orderId;
  final String newStatus;

  const UpdateOrderStatus({required this.orderId, required this.newStatus});

  @override
  List<Object> get props => [orderId, newStatus];
}