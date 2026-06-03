// lib/Core/Provider/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Core/Model/item_model.dart';

class CartItem {
  final AppModel product;
  final int quantity;

  CartItem({required this.product, this.quantity = 1});

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);
}

class CartState {
  final List<CartItem> items;

  CartState({required this.items});

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      items.fold(0, (sum, item) => sum + item.product.price * item.quantity);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState(items: []));

  void addToCart(AppModel product) {
    final index =
        state.items.indexWhere((i) => i.product.image == product.image);
    if (index >= 0) {
      final updated = List<CartItem>.from(state.items);
      updated[index] =
          updated[index].copyWith(quantity: updated[index].quantity + 1);
      state = CartState(items: updated);
    } else {
      state = CartState(items: [...state.items, CartItem(product: product)]);
    }
  }

  void removeFromCart(AppModel product) {
    state = CartState(
      items: state.items
          .where((i) => i.product.image != product.image)
          .toList(),
    );
  }

  void decreaseQuantity(AppModel product) {
    final index =
        state.items.indexWhere((i) => i.product.image == product.image);
    if (index >= 0) {
      if (state.items[index].quantity > 1) {
        final updated = List<CartItem>.from(state.items);
        updated[index] =
            updated[index].copyWith(quantity: updated[index].quantity - 1);
        state = CartState(items: updated);
      } else {
        removeFromCart(product);
      }
    }
  }

  void clearCart() => state = CartState(items: []);
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);