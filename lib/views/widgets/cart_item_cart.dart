import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electronics_shop_app/models/cart_item.dart';
import 'package:electronics_shop_app/viewmodels/cart_view_model.dart';

class CartItemCard extends ConsumerWidget {
  final CartItem item;
  final int index;

  const CartItemCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductThumbnail(item: item),
            const SizedBox(width: 12),
            Expanded(
              child: _ProductDetails(item: item, theme: theme),
            ),
            _QuantityControls(
              item: item,
              index: index,
              cartNotifier: cartNotifier,
              onRemove: () => _showRemovalSnackbar(context, item),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemovalSnackbar(BuildContext context, CartItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.product.title} removed from cart'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  final CartItem item;

  const _ProductThumbnail({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        item.product.thumbnail,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 70,
          height: 70,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      ),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  final CartItem item;
  final ThemeData theme;

  const _ProductDetails({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.product.title,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          item.product.brand,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        _PriceDisplay(item: item, theme: theme),
      ],
    );
  }
}

class _PriceDisplay extends StatelessWidget {
  final CartItem item;
  final ThemeData theme;

  const _PriceDisplay({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '₹${item.product.discountedPrice.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (item.product.price != item.product.discountedPrice) ...[
          Text(
            '₹${item.product.price.toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${item.product.discountPercentage.toStringAsFixed(0)}% OFF',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuantityControls extends StatelessWidget {
  final CartItem item;
  final int index;
  final CartNotifier cartNotifier;
  final VoidCallback onRemove;

  const _QuantityControls({
    required this.item,
    required this.index,
    required this.cartNotifier,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _QuantityButton(
              icon: Icons.remove,
              onPressed: () => cartNotifier.decrementQuantity(index),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _QuantityButton(
              icon: Icons.add,
              onPressed: () => cartNotifier.incrementQuantity(index),
            ),
          ],
        ),
        const SizedBox(height: 8),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            cartNotifier.removeFromCart(index);
            onRemove();
          },
          tooltip: 'Remove item',
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey[200],
        padding: const EdgeInsets.all(4),
        minimumSize: const Size(36, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}