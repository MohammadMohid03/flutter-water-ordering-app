import 'package:cloud_firestore/cloud_firestore.dart' hide Order; // Hide the conflicting class
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spinza/data/models/cart_item_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  OrderRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> placeOrder({
    required List<CartItem> items,
    required String address,
    required String city,
    required String deliveryDay,
    required String paymentMethod,
  }) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    final batch = _firestore.batch();

    // Construct the full address
    final fullAddress = '$address, $city';

    for (final item in items) {
      final newOrderRef = _firestore.collection('orders').doc();
      final userOrderRef = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('orders')
          .doc(newOrderRef.id);

      final orderData = {
        'userId': currentUser.uid,
        'userName': currentUser.displayName,
        'userEmail': currentUser.email!,
        'address': fullAddress, // Use the combined full address
        'deliveryDay': deliveryDay,
        'paymentMethod': paymentMethod,
        'productId': item.product.id,
        'productName': item.product.name,
        'quantity': item.quantity,
        'totalPrice': item.product.price * item.quantity,
        'orderDate': Timestamp.now(),
        'status': 'Pending', // Add a default order status
      };

      batch.set(newOrderRef, orderData);
      batch.set(userOrderRef, orderData);
    }

    await batch.commit();
  }
  // --- NEW METHOD TO FETCH CLIENT'S OWN ORDERS ---
  Future<List<QueryDocumentSnapshot>> fetchMyOrders() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      // If the user is not logged in, return an empty list.
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('orders')
          .orderBy('orderDate', descending: true) // Show most recent first
          .get();
      return snapshot.docs;
    } catch (e) {
      print("Error fetching client's orders: $e");
      rethrow;
    }
  }
}