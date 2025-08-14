import 'package:equatable/equatable.dart';
import 'package:spinza/data/models/order_model.dart';
import 'package:spinza/data/models/cart_item_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object> get props => [];
}

class CreateOrder extends OrderEvent {
  final List<CartItem> items;
  final String address;
  final String city;
  final String deliveryDay;
  final String paymentMethod;

  const CreateOrder({
    required this.items,
    required this.address,
    required this.city,
    required this.deliveryDay,
    required this.paymentMethod,
  });

  @override
  List<Object> get props => [items, address, city, deliveryDay, paymentMethod];
}