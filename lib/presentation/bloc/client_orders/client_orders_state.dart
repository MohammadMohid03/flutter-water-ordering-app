import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class ClientOrdersState extends Equatable {
  const ClientOrdersState();
  @override
  List<Object> get props => [];
}

class ClientOrdersInitial extends ClientOrdersState {}
class ClientOrdersLoading extends ClientOrdersState {}
class ClientOrdersLoaded extends ClientOrdersState {
  final List<QueryDocumentSnapshot> orders;
  const ClientOrdersLoaded(this.orders);
  @override
  List<Object> get props => [orders];
}
class ClientOrdersError extends ClientOrdersState {
  final String message;
  const ClientOrdersError(this.message);
  @override
  List<Object> get props => [message];
}