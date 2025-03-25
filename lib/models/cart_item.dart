import 'package:hive/hive.dart';
import 'package:electronics_shop_app/models/product.dart';

part 'cart_item.g.dart';

@HiveType(typeId: 1)
class CartItem extends HiveObject {
  @HiveField(0)
  final Product product;

  @HiveField(1)
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice {
    return product.discountedPrice * quantity;
  }

  void incrementQuantity() {
    quantity++;
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }
}

