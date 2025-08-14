import 'dart:io'; // <-- Import dart:io to use the File type
import 'package:equatable/equatable.dart';

/// The base class for all product-related events.
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Event to signal the BLoC to fetch all products from the repository.
class FetchProducts extends ProductEvent {}

/// Event to signal the BLoC to add a new product.
class AddProduct extends ProductEvent {
  final String name;
  final String description;
  final double price;
  final File imageFile; // <-- CHANGED: Takes a File object for uploading.

  const AddProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.imageFile,
  });

  @override
  List<Object> get props => [name, description, price, imageFile];
}

/// Event to signal the BLoC to update an existing product.
class UpdateProduct extends ProductEvent {
  final String productId;
  final String name;
  final String description;
  final double price;
  final File? imageFile; // <-- CHANGED: An optional new File for uploading.
  final String? existingImageUrl; // <-- ADDED: The old URL/path.

  const UpdateProduct({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    this.imageFile,
    this.existingImageUrl,
  });

  @override
  List<Object?> get props => [
    productId,
    name,
    description,
    price,
    imageFile,
    existingImageUrl,
  ];
}

/// Event to signal the BLoC to delete a product.
class DeleteProduct extends ProductEvent {
  final String productId;
  final String imageUrl; // <-- ADDED: Needed to know if we delete from Storage.

  const DeleteProduct({required this.productId, required this.imageUrl});

  @override
  List<Object> get props => [productId, imageUrl];
}