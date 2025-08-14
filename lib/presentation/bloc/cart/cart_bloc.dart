import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/data/models/cart_item_model.dart';
import 'package:spinza/presentation/bloc/cart/cart_event.dart';
import 'package:spinza/presentation/bloc/cart/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartItemQuantityIncreased>(_onItemQuantityIncreased);
    on<CartItemQuantityDecreased>(_onItemQuantityDecreased);
    on<CartCleared>(_onCartCleared);
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    final List<CartItem> updatedItems = List.from(state.items);
    final int index = updatedItems.indexWhere((item) => item.product.id == event.product.id);

    if (index != -1) {
      // Product already in cart, increase quantity
      final existingItem = updatedItems[index];
      updatedItems[index] = existingItem.copyWith(quantity: existingItem.quantity + 1);
    } else {
      // Product not in cart, add it
      updatedItems.add(CartItem(product: event.product, quantity: 1));
    }
    emit(CartState(items: updatedItems));
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    final List<CartItem> updatedItems = List.from(state.items);
    updatedItems.removeWhere((item) => item.product.id == event.cartItem.product.id);
    emit(CartState(items: updatedItems));
  }

  void _onItemQuantityIncreased(CartItemQuantityIncreased event, Emitter<CartState> emit) {
    final List<CartItem> updatedItems = List.from(state.items);
    final int index = updatedItems.indexWhere((item) => item.product.id == event.cartItem.product.id);
    if (index != -1) {
      final existingItem = updatedItems[index];
      updatedItems[index] = existingItem.copyWith(quantity: existingItem.quantity + 1);
      emit(CartState(items: updatedItems));
    }
  }

  void _onItemQuantityDecreased(CartItemQuantityDecreased event, Emitter<CartState> emit) {
    final List<CartItem> updatedItems = List.from(state.items);
    final int index = updatedItems.indexWhere((item) => item.product.id == event.cartItem.product.id);
    if (index != -1) {
      final existingItem = updatedItems[index];
      if (existingItem.quantity > 1) {
        updatedItems[index] = existingItem.copyWith(quantity: existingItem.quantity - 1);
      } else {
        // If quantity is 1, remove the item
        updatedItems.removeAt(index);
      }
      emit(CartState(items: updatedItems));
    }
  }

  void _onCartCleared(CartCleared event, Emitter<CartState> emit) {
    emit(const CartState(items: []));
  }
}