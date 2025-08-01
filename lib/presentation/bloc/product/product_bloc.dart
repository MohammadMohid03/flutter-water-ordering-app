import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/data/repositories/product_repository.dart';
import 'package:spinza/presentation/bloc/product/product_event.dart';
import 'package:spinza/presentation/bloc/product/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(ProductInitial()) {
    // --- REGISTER ALL EVENT HANDLERS HERE ---
    on<FetchProducts>(_onFetchProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  // This handler is unchanged
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

  // --- NEW HANDLER for AddProduct ---
  Future<void> _onAddProduct(
      AddProduct event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.addProduct(
        name: event.name,
        description: event.description,
        price: event.price,
        imageAssetPath: event.imageAssetPath,
      );
      // After adding, refresh the product list
      add(FetchProducts());
    } catch (e) {
      emit(const ProductError("Failed to add product. Please try again."));
    }
  }

  // --- NEW HANDLER for UpdateProduct ---
  Future<void> _onUpdateProduct(
      UpdateProduct event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.updateProduct(
        productId: event.productId,
        name: event.name,
        description: event.description,
        price: event.price,
        imageAssetPath: event.imageAssetPath,
      );
      // After updating, refresh the product list
      add(FetchProducts());
    } catch (e) {
      emit(const ProductError("Failed to update product. Please try again."));
    }
  }

  // --- NEW HANDLER for DeleteProduct ---
  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.deleteProduct(event.productId);
      // After deleting, refresh the product list
      add(FetchProducts());
    } catch (e) {
      emit(const ProductError("Failed to delete product. Please try again."));
    }
  }
}