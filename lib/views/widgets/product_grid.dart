import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electronics_shop_app/viewmodels/product_view_model.dart';
import 'package:electronics_shop_app/views/widgets/product_card.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final productsNotifier = ref.read(productsProvider.notifier);

    if (productsState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${productsState.errorMessage}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => productsNotifier.fetchProducts(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (productsState.products.isEmpty && productsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (productsState.products.isEmpty) {
      return const Center(
        child: Text('No products found'),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!productsState.isLoading && 
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          productsNotifier.loadMore();
          return true;
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: productsState.products.length + (productsState.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= productsState.products.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          final product = productsState.products[index];
          return ProductCard(product: product);
        },
      ),
    );
  }
}