import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electronics_shop_app/models/cart_item.dart';
import 'package:electronics_shop_app/models/product.dart';
import 'package:electronics_shop_app/services/cart_service.dart';

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService();
});

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final cartService = ref.watch(cartServiceProvider);
  return CartNotifier(cartService);
});

class CartState {
  final List<CartItem> items;
  final double totalPrice;

  CartState({
    this.items = const [],
    this.totalPrice = 0.0,
  });

  CartState copyWith({
    List<CartItem>? items,
    double? totalPrice,
  }) {
    return CartState(
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final CartService _cartService;

  CartNotifier(this._cartService) : super(CartState()) {
    refreshCart();
  }

  void refreshCart() {
    final items = _cartService.getCartItems();
    final totalPrice = _cartService.getTotalPrice();
    state = state.copyWith(
      items: items,
      totalPrice: totalPrice,
    );
  }

  Future<void> addToCart(Product product) async {
    await _cartService.addToCart(product);
    refreshCart();
  }

  Future<void> removeFromCart(int index) async {
    await _cartService.removeFromCart(index);
    refreshCart();
  }

  Future<void> incrementQuantity(int index) async {
    await _cartService.incrementQuantity(index);
    refreshCart();
  }

  Future<void> decrementQuantity(int index) async {
    await _cartService.decrementQuantity(index);
    refreshCart();
  }

  Future<void> clearCart() async {
    await _cartService.clearCart();
    refreshCart();
  }

  int getCartItemCount() {
    return _cartService.getCartItemCount();
  }
}

