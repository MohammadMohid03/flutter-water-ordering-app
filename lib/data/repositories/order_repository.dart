import 'package:cloud_firestore/cloud_firestore.dart' hide Order; // Hide the conflicting class
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spinza/data/models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  OrderRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> placeOrder(Order order) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final newOrderRef = _firestore.collection('orders').doc();
    final userOrderRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('orders')
        .doc(newOrderRef.id);

    final orderData = {
      'userId': currentUser.uid,
      'userName': currentUser.displayName, // This now has a value thanks to the auth_repository fix
      'userEmail': currentUser.email!,
      'productId': order.product.id,
      'productName': order.product.name,
      'quantity': order.quantity,
      'totalPrice': order.totalPrice,
      'orderDate': Timestamp.now(),
    };

    final batch = _firestore.batch();
    batch.set(newOrderRef, orderData);
    batch.set(userOrderRef, orderData);
    await batch.commit();
  }
}