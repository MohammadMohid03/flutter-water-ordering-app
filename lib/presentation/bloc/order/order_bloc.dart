import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/core/utils/app_strings.dart';
import 'package:spinza/data/repositories/order_repository.dart';
import 'package:spinza/presentation/bloc/order/order_event.dart';
import 'package:spinza/presentation/bloc/order/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    on<CreateOrder>(_onCreateOrder);
  }

  Future<void> _onCreateOrder(CreateOrder event, Emitter<OrderState> emit) async {
    emit(OrderInProgress());
    try {
      await orderRepository.placeOrder(event.order);
      emit(OrderSuccess(event.order));
    } catch (_) {
      emit(const OrderFailure(AppStrings.anErrorOccurred));
    }
  }
}