import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:spinza/data/models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;

  ProductRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? firebaseStorage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

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

  // --- RE-INTRODUCE IMAGE UPLOAD LOGIC ---
  Future<String> _uploadImage(File imageFile, String productId) async {
    final ref = _firebaseStorage.ref().child('product_images').child('$productId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // --- UPDATED addProduct METHOD ---
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required File imageFile, // Takes a File for new products
  }) async {
    final newDocRef = _firestore.collection('products').doc();
    final imageUrl = await _uploadImage(imageFile, newDocRef.id);
    await newDocRef.set({
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl, // This will be an 'http' URL
    });
  }

  // --- UPDATED updateProduct METHOD ---
  Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    File? imageFile, // Optional new image file
    String? existingImageUrl, // The old URL (could be asset or network)
  }) async {
    String imageUrl = existingImageUrl ?? '';

    // If a new file is provided, upload it and get the new URL
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, productId);
    }

    await _firestore.collection('products').doc(productId).update({
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl, // Save either the new URL or the old one
    });
  }

  // --- UPDATED deleteProduct METHOD ---
  Future<void> deleteProduct(String productId, String imageUrl) async {
    await _firestore.collection('products').doc(productId).delete();
    // Only try to delete from Storage if it's a network image
    if (imageUrl.startsWith('http')) {
      final ref = _firebaseStorage.refFromURL(imageUrl);
      try {
        await ref.delete();
      } catch (e) {
        print("Info: Could not delete image $imageUrl. Error: $e");
      }
    }
  }
}