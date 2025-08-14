import 'package:equatable/equatable.dart';

abstract class ClientOrdersEvent extends Equatable {
  const ClientOrdersEvent();
  @override
  List<Object> get props => [];
}

class FetchMyOrders extends ClientOrdersEvent {}