import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/data/repositories/admin_order_repository.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_event.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_state.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

class AdminOrdersBloc extends Bloc<AdminOrdersEvent, AdminOrdersState> {
  final AdminOrderRepository _adminOrderRepository;

  AdminOrdersBloc({required AdminOrderRepository adminOrderRepository})
      : _adminOrderRepository = adminOrderRepository,
        super(AdminOrdersInitial()) {
    on<FetchAllOrders>(_onFetchAllOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus,transformer: sequential()); // <-- REGISTER NEW HANDLER
  }

  Future<void> _onFetchAllOrders(FetchAllOrders event, Emitter<AdminOrdersState> emit) async {
    emit(AdminOrdersLoading());
    try {
      final allOrders = await _adminOrderRepository.fetchAllOrders();

      final Map<String, List<QueryDocumentSnapshot>> groupedOrders = {};
      for (var order in allOrders) {
        final userId = order['userId'] as String;
        if (groupedOrders[userId] == null) {
          groupedOrders[userId] = [];
        }
        groupedOrders[userId]!.add(order);
      }

      final List<ClientOrderSummary> summaries = [];
      groupedOrders.forEach((userId, orders) {
        double totalSpent = 0;
        for (var order in orders) {
          totalSpent += (order['totalPrice'] as num).toDouble();
        }

        // --- DEFENSIVE FIX FOR NULL USERNAMES ---
        final clientName = orders.first['userName'] as String? ?? 'Unknown Client';
        final clientEmail = orders.first['userEmail'] as String? ?? 'N/A';

        summaries.add(ClientOrderSummary(
          clientId: userId,
          clientName: clientName,
          clientEmail: clientEmail,
          totalOrders: orders.length,
          totalSpent: totalSpent,
          lastOrderDate: orders.first['orderDate'],
          orders: orders,
        ));
      });

      summaries.sort((a,b) => b.lastOrderDate.compareTo(a.lastOrderDate));

      emit(AdminOrdersLoaded(summaries));
    } catch (e) {
      emit(AdminOrdersError(e.toString()));
    }
  }
  // --- THIS HANDLER IS REVISED ---
  Future<void> _onUpdateOrderStatus(UpdateOrderStatus event, Emitter<AdminOrdersState> emit) async {
    try {
      await _adminOrderRepository.updateOrderStatus(event.orderId, event.newStatus);
      // After the update is complete, dispatch a new event to refresh the list.
      // The sequential transformer ensures this runs after the update is fully processed.
      add(FetchAllOrders());
    } catch (e) {
      emit(const AdminOrdersError("Failed to update status."));
    }
  }
}