import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double revenueThisMonth;
  final int ordersThisMonth;
  final List<QueryDocumentSnapshot> monthlySummaries;

  const DashboardLoaded({
    required this.revenueThisMonth,
    required this.ordersThisMonth,
    required this.monthlySummaries,
  });

  @override
  List<Object> get props => [revenueThisMonth, ordersThisMonth, monthlySummaries];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object> get props => [message];
}