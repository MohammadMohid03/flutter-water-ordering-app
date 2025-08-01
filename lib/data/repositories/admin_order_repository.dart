import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderRepository {
  final FirebaseFirestore _firestore;
  AdminOrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Fetches ALL orders from the top-level collection
  Future<List<QueryDocumentSnapshot>> fetchAllOrders() async {
    try {
      final snapshot = await _firestore.collection('orders').orderBy('orderDate', descending: true).get();
      return snapshot.docs;
    } catch (e) {
      print('Error fetching all orders: $e');
      rethrow;
    }
  }
}