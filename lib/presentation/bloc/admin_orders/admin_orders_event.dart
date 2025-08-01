import 'package:equatable/equatable.dart';

abstract class AdminOrdersEvent extends Equatable {
  const AdminOrdersEvent();
  @override
  List<Object> get props => [];
}

class FetchAllOrders extends AdminOrdersEvent {}