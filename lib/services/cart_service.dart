import 'package:hive/hive.dart';
import 'package:electronics_shop_app/models/cart_item.dart';
import 'package:electronics_shop_app/models/product.dart';

class CartService {
  final Box<CartItem> _cartBox = Hive.box<CartItem>('cart');

  List<CartItem> getCartItems() {
    return _cartBox.values.toList();
  }

  Future<void> addToCart(Product product) async {
    // Check if product already exists in cart
    final existingItemIndex = _cartBox.values.toList().indexWhere(
          (item) => item.product.id == product.id,
        );

    if (existingItemIndex != -1) {
      // If product exists, increment quantity
      final existingItem = _cartBox.getAt(existingItemIndex)!;
      existingItem.incrementQuantity();
      await _cartBox.putAt(existingItemIndex, existingItem);
    } else {
      // If product doesn't exist, add new cart item
      await _cartBox.add(CartItem(product: product));
    }
  }

  Future<void> removeFromCart(int index) async {
    await _cartBox.deleteAt(index);
  }

  Future<void> incrementQuantity(int index) async {
    final item = _cartBox.getAt(index)!;
    item.incrementQuantity();
    await _cartBox.putAt(index, item);
  }

  Future<void> decrementQuantity(int index) async {
    final item = _cartBox.getAt(index)!;
    if (item.quantity > 1) {
      item.decrementQuantity();
      await _cartBox.putAt(index, item);
    } else {
      await removeFromCart(index);
    }
  }

  Future<void> clearCart() async {
    await _cartBox.clear();
  }

  double getTotalPrice() {
    return _cartBox.values.fold(
      0,
      (total, item) => total + item.totalPrice,
    );
  }

  int getCartItemCount() {
    return _cartBox.length;
  }
}

