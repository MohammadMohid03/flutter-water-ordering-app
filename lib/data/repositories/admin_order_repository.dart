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
  // --- NEW METHOD TO UPDATE ORDER STATUS ---
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // We need to update the status in BOTH locations for consistency.
      final batch = _firestore.batch();

      // 1. Get the user ID from the main order document
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) throw Exception("Order not found");
      final userId = orderDoc.data()!['userId'];

      // 2. Reference in top-level 'orders' collection
      final mainOrderRef = _firestore.collection('orders').doc(orderId);
      batch.update(mainOrderRef, {'status': newStatus});

      // 3. Reference in user's 'orders' subcollection
      final userOrderRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId);
      batch.update(userOrderRef, {'status': newStatus});

      // 4. Commit the atomic update
      await batch.commit();

    } catch (e) {
      print("Error updating order status: $e");
      rethrow;
    }
  }
  Future<List<QueryDocumentSnapshot>> fetchMonthlySummaries() async {
    final snapshot = await _firestore
        .collection('monthly_summaries')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }

  // --- NEW METHOD to fetch live data for the current month ---
  Future<List<QueryDocumentSnapshot>> fetchCurrentMonthOrders() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final snapshot = await _firestore
        .collection('orders')
        .where('orderDate', isGreaterThanOrEqualTo: startOfMonth)
        .get();
    return snapshot.docs;
  }
}