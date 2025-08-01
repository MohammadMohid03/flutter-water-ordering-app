import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spinza/data/models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num).toDouble(),
          imageUrl: data['imageUrl'] ?? '', // This will be the asset path
        );
      }).toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  // Adds a product using a string path for the image
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required String imageAssetPath,
  }) async {
    try {
      await _firestore.collection('products').add({
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageAssetPath, // Save the asset path directly
      });
    } catch (e) {
      rethrow;
    }
  }

  // Updates a product using a string path for the image
  Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required String imageAssetPath,
  }) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageAssetPath, // Save the asset path directly
      });
    } catch (e) {
      rethrow;
    }
  }

  // Deletes a product from Firestore (no storage interaction needed)
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      rethrow;
    }
  }
}