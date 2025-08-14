import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/data/repositories/order_repository.dart';
import 'package:spinza/presentation/bloc/cart/cart_bloc.dart';
import 'package:spinza/presentation/bloc/cart/cart_event.dart';
import 'package:spinza/presentation/bloc/order/order_event.dart';
import 'package:spinza/presentation/bloc/order/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;
  final CartBloc cartBloc;

  OrderBloc({required this.orderRepository, required this.cartBloc}) : super(OrderInitial()) {
    on<CreateOrder>(_onCreateOrder);
  }

  Future<void> _onCreateOrder(CreateOrder event, Emitter<OrderState> emit) async {
    emit(OrderInProgress());
    try {
      // --- THIS IS THE CHANGE ---
      // 1. Capture the total price before it's cleared.
      double totalPrice = event.items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

      // 2. Place the order.
      await orderRepository.placeOrder(
        items: event.items,
        address: event.address,
        city: event.city,
        deliveryDay: event.deliveryDay,
        paymentMethod: event.paymentMethod,
      );

      // 3. Emit the success state WITH the order data.
      emit(OrderSuccess(orderedItems: event.items, totalPrice: totalPrice));

      // 4. Clear the cart AFTER the success state has been emitted.
      cartBloc.add(CartCleared());

    } catch (_) {
      emit(const OrderFailure("Failed to place order."));
    }
  }
}