import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electronics_shop_app/models/product.dart';
import 'package:electronics_shop_app/viewmodels/cart_view_model.dart';
import 'package:electronics_shop_app/viewmodels/favorite_view_model.dart';
import 'package:electronics_shop_app/viewmodels/product_view_model.dart';
import 'package:electronics_shop_app/views/widgets/product_card.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  int _quantity = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final isFavorite = ref.watch(favoritesProvider).contains(widget.product);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    final allProducts = ref.watch(productsProvider);
    
    // Get related products (same category)
    final relatedProducts = allProducts.products
        .where((p) => p.category == widget.product.category && p.id != widget.product.id)
        .take(6)
        .toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[700],
                    ),
                  ),
                  onPressed: () {
                    if (isFavorite) {
                      favoritesNotifier.removeFromFavorites(widget.product);
                    } else {
                      favoritesNotifier.addToFavorites(widget.product);
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery
                  AspectRatio(
                    aspectRatio: isTablet ? 16 / 9 : 1,
                    child: Stack(
                      children: [
                        // Main Image Carousel
                        PageView.builder(
                          controller: _pageController,
                          itemCount: widget.product.images.length > 0 
                              ? widget.product.images.length 
                              : 1,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final imageUrl = widget.product.images.isNotEmpty 
                                ? widget.product.images[index]
                                : widget.product.thumbnail;
                            
                            return GestureDetector(
                              onTap: () {
                                // Show full screen image view
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImageView(
                                      imageUrls: widget.product.images.isNotEmpty 
                                          ? widget.product.images 
                                          : [widget.product.thumbnail],
                                      initialIndex: _currentImageIndex,
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'product_image_${widget.product.id}_$index',
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
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
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // Discount Badge
                        if (widget.product.discountPercentage > 0)
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${widget.product.discountPercentage.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          
                        // Navigation Arrows
                        if (widget.product.images.length > 1) ...[
                          // Left Arrow
                          Positioned(
                            left: 8,
                            top: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                if (_currentImageIndex > 0) {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          
                          // Right Arrow
                          Positioned(
                            right: 8,
                            top: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                if (_currentImageIndex < widget.product.images.length - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                        
                        // Image Indicators
                        if (widget.product.images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                widget.product.images.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Thumbnail Gallery
                  if (widget.product.images.length > 1)
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.product.images.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _currentImageIndex == index
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.withOpacity(0.3),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  widget.product.images[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 24,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Brand
                        Text(
                          widget.product.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Brand: ${widget.product.brand}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Rating and Stock
                        Row(
                          children: [
                            // Rating
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.product.rating.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Stock
                            Icon(
                              Icons.inventory_2,
                              size: 16,
                              color: widget.product.stock > 0 ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.product.stock > 0
                                  ? 'In Stock (${widget.product.stock})'
                                  : 'Out of Stock',
                              style: TextStyle(
                                color: widget.product.stock > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${widget.product.discountedPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (widget.product.discountPercentage > 0) ...[
                              const SizedBox(width: 12),
                              Text(
                                '₹${widget.product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Quantity Selector
                        Row(
                          children: [
                            const Text(
                              'Quantity:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  // Decrease Button
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: _quantity > 1
                                        ? () {
                                            setState(() {
                                              _quantity--;
                                            });
                                          }
                                        : null,
                                    color: _quantity > 1
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                  ),
                                  
                                  // Quantity
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(color: Colors.grey[300]!),
                                        right: BorderSide(color: Colors.grey[300]!),
                                      ),
                                    ),
                                    child: Text(
                                      _quantity.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  
                                  // Increase Button
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: _quantity < widget.product.stock
                                        ? () {
                                            setState(() {
                                              _quantity++;
                                            });
                                          }
                                        : null,
                                    color: _quantity < widget.product.stock
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.product.stock > 0
                                ? () {
                                    for (var i = 0; i < _quantity; i++) {
                                      cartNotifier.addToCart(widget.product);
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '$_quantity ${widget.product.title} added to cart',
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Buy Now Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: widget.product.stock > 0
                                ? () {
                                    // Implement buy now functionality
                                  }
                                : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Buy Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Related Products
                        if (relatedProducts.isNotEmpty) ...[
                          const Text(
                            'Related Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 280,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: relatedProducts.length,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: 180,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: ProductCard(
                                      product: relatedProducts[index],
                                      isHorizontal: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Full Screen Image View
class FullScreenImageView extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageView({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late PageController _pageController;
  late int _currentIndex;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1}/${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Hero(
                  tag: 'product_image_${index}',
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                          size: 64,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}