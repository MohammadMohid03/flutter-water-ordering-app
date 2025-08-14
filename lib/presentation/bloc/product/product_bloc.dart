import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:spinza/data/models/product_model.dart';
import 'package:spinza/data/repositories/product_repository.dart';
import 'package:spinza/presentation/bloc/product/product_event.dart';
import 'package:spinza/presentation/bloc/product/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct, transformer: sequential());
  }

  Future<void> _onFetchProducts(
      FetchProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _productRepository.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
      AddProduct event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.addProduct(
        name: event.name,
        description: event.description,
        price: event.price,
        imageFile: event.imageFile,
      );
      add(FetchProducts());
    } catch (e) {
      emit(const ProductError("Failed to add product. Please try again."));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.updateProduct(
        productId: event.productId,
        name: event.name,
        description: event.description,
        price: event.price,
        imageFile: event.imageFile,
        existingImageUrl: event.existingImageUrl,
      );
      add(FetchProducts());
    } catch (e) {
      emit(const ProductError("Failed to update product. Please try again."));
    }
  }

  // --- THIS IS THE SIMPLIFIED AND MORE ROBUST HANDLER ---
  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<ProductState> emit) async {
    try {
      // 1. Tell the repository to delete the product from Firestore and Storage.
      await _productRepository.deleteProduct(event.productId, event.imageUrl);

      // 2. After the deletion is successful, simply dispatch a FetchProducts event.
      // This will cause the BLoC to re-fetch the now-updated list from the database,
      // ensuring the UI is perfectly in sync with the data.
      add(FetchProducts());
    } catch (e) {
      emit(const ProductError("Failed to delete product. Please try again."));
    }
  }
}