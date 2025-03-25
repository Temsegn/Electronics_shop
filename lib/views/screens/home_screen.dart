import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electronics_shop_app/models/product.dart';
import 'package:electronics_shop_app/viewmodels/cart_view_model.dart';
import 'package:electronics_shop_app/viewmodels/product_view_model.dart';
import 'package:electronics_shop_app/views/screens/cart_screen.dart';
import 'package:electronics_shop_app/views/screens/favorite_screen.dart';
import 'package:electronics_shop_app/views/screens/account_screen.dart';
import 'package:electronics_shop_app/views/widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(cartProvider.select((cart) => cart.items.length));
    final isTablet = MediaQuery.of(context).size.width > 600;
    final productsState = ref.watch(productsProvider);
    final topRatedProducts = ref.read(productsProvider.notifier).getTopRatedProducts();

    final screens = [
      _buildHomeContent(topRatedProducts, productsState),
      const FavoritesScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      appBar: _buildAppBar(cartItemCount),
      body: screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: isTablet && cartItemCount > 0 && _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              child: const Icon(Icons.shopping_cart),
            )
          : null,
    );
  }

  /// **🔹 Modern App Bar**
  AppBar _buildAppBar(int cartItemCount) {
    return AppBar(
      title: AnimatedCrossFade(
        firstChild: const Text('Tech Haven', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        secondChild: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search products...',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              ref.read(productsProvider.notifier).searchProducts(value);
            }
          },
        ),
        crossFadeState: _isSearching ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                ref.read(productsProvider.notifier).fetchProducts(refresh: true);
              }
            });
          },
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            ),
            if (cartItemCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text('$cartItemCount', style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// **🔹 Home Content with Horizontal Scroll for Top Products**
  Widget _buildHomeContent(List<Product> topRatedProducts, ProductsState productsState) {
    return RefreshIndicator(
      onRefresh: () async => ref.read(productsProvider.notifier).fetchProducts(refresh: true),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSectionTitle('Top Rated Products', () {}),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: topRatedProducts.isEmpty
                  ? const Center(child: Text('No top-rated products found'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: topRatedProducts.length,
                      itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ProductCard(product: topRatedProducts[index], isHorizontal: true),
                      ),
                    ),
            ),
          ),
          _buildSectionTitle('All Products', () {}),
          productsState.isLoading && productsState.products.isEmpty
              ? const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                )
              : productsState.errorMessage != null
                  ? SliverToBoxAdapter(
                      child: Center(child: Text('Error: ${productsState.errorMessage}')),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => ProductCard(product: productsState.products[index]),
                          childCount: productsState.products.length,
                        ),
                      ),
                    ),
          if (productsState.isLoading && productsState.products.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  /// **🔹 Bottom Navigation with Modern Look**
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      backgroundColor: Colors.white,
      elevation: 10,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        _buildNavBarItem(Icons.home, "Home"),
        _buildNavBarItem(Icons.favorite, "Favorites"),
        _buildNavBarItem(Icons.person, "Account"),
      ],
    );
  }

  BottomNavigationBarItem _buildNavBarItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: _currentIndex == 0 ? 6 : 0),
        child: Icon(icon, size: _currentIndex == 0 ? 28 : 24),
      ),
      label: label,
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onTap) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: onTap, child: const Text('See All')),
          ],
        ),
      ),
    );
  }
}
