import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/data/repositories/order_repository.dart';
import 'package:spinza/presentation/bloc/client_orders/client_orders_event.dart';
import 'package:spinza/presentation/bloc/client_orders/client_orders_state.dart';

class ClientOrdersBloc extends Bloc<ClientOrdersEvent, ClientOrdersState> {
  final OrderRepository _orderRepository;

  ClientOrdersBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(ClientOrdersInitial()) {
    on<FetchMyOrders>(_onFetchMyOrders);
  }

  Future<void> _onFetchMyOrders(
      FetchMyOrders event, Emitter<ClientOrdersState> emit) async {
    emit(ClientOrdersLoading());
    try {
      final orders = await _orderRepository.fetchMyOrders();
      emit(ClientOrdersLoaded(orders));
    } catch (e) {
      emit(ClientOrdersError(e.toString()));
    }
  }
}