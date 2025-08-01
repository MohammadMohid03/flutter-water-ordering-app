import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ClientOrderSummary extends Equatable {
  final String clientId;
  final String clientName;
  final String clientEmail;
  final int totalOrders;
  final double totalSpent;
  final Timestamp lastOrderDate;
  final List<QueryDocumentSnapshot> orders;

  const ClientOrderSummary({
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.totalOrders,
    required this.totalSpent,
    required this.lastOrderDate,
    required this.orders,
  });

  @override
  List<Object?> get props => [clientId, totalOrders, totalSpent];
}

abstract class AdminOrdersState extends Equatable {
  const AdminOrdersState();
  @override
  List<Object> get props => [];
}

class AdminOrdersInitial extends AdminOrdersState {}
class AdminOrdersLoading extends AdminOrdersState {}
class AdminOrdersLoaded extends AdminOrdersState {
  final List<ClientOrderSummary> clientSummaries;
  const AdminOrdersLoaded(this.clientSummaries);
  @override
  List<Object> get props => [clientSummaries];
}
class AdminOrdersError extends AdminOrdersState {
  final String message;
  const AdminOrdersError(this.message);
  @override
  List<Object> get props => [message];
}