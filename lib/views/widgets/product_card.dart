import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electronics_shop_app/models/product.dart';
import 'package:electronics_shop_app/viewmodels/cart_view_model.dart';
import 'package:electronics_shop_app/viewmodels/favorite_view_model.dart';
import 'package:electronics_shop_app/views/screens/product_detail_screen.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final bool isHorizontal;

  const ProductCard({
    super.key, 
    required this.product,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final isFavorite = ref.watch(favoritesProvider).contains(product);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonPadding = screenWidth < 600 ? 8.0 : 12.0;
    final badgeFontSize = screenWidth < 600 ? 10.0 : 12.0;

    return GestureDetector(
      onTap: () {
        // Navigate to product details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 300 : 200,
            minHeight: isHorizontal ? 180 : 200,
            maxHeight: isHorizontal ? 230 : 250,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Section with Add Button
              AspectRatio(
                aspectRatio: isHorizontal ? 1.3 : 1.5,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        product.thumbnail,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    // Discount Badge
                    if (product.discountPercentage > 0)
                      Positioned(
                        top: 5,
                        left: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: badgeFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Favorite Button
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: const EdgeInsets.all(4),
                          onPressed: () {
                            if (isFavorite) {
                              favoritesNotifier.removeFromFavorites(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Removed from favorites'),
                                  backgroundColor: Colors.grey[800],
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            } else {
                              favoritesNotifier.addToFavorites(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added to favorites'),
                                  backgroundColor: Colors.red[400],
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    // Add Button
                    Positioned(
                      bottom: 3,
                      right: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          cartNotifier.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${product.title} added to cart',
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: buttonPadding,
                            vertical: 4,
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(0, 0),
                        ),
                        child: Text(
                          'Add',
                          style: TextStyle(
                            fontSize: screenWidth < 600 ? 12 : 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content Section
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Brand
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        product.brand,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Price Row
                    Row(
                      children: [
                        Text(
                          '₹${product.discountedPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.price != product.discountedPrice)
                          Text(
                            '₹${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}