import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/data/repositories/admin_order_repository.dart';
import 'package:spinza/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:spinza/presentation/bloc/dashboard/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final AdminOrderRepository _adminOrderRepository;

  DashboardBloc({required AdminOrderRepository adminOrderRepository})
      : _adminOrderRepository = adminOrderRepository,
        super(DashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
  }

  Future<void> _onFetchDashboardData(
      FetchDashboardData event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      // Fetch both sets of data in parallel
      final results = await Future.wait([
        _adminOrderRepository.fetchCurrentMonthOrders(),
        _adminOrderRepository.fetchMonthlySummaries(),
      ]);

      final currentMonthOrders = results[0];
      final monthlySummaries = results[1];

      double revenueThisMonth = 0;
      for (var doc in currentMonthOrders) {
        revenueThisMonth += (doc.data() as Map<String, dynamic>)['totalPrice'] ?? 0;
      }

      emit(DashboardLoaded(
        revenueThisMonth: revenueThisMonth,
        ordersThisMonth: currentMonthOrders.length,
        monthlySummaries: monthlySummaries,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}