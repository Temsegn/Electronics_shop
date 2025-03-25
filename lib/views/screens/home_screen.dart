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

    final screens = [
      Consumer(
        builder: (context, ref, child) {
          final topRatedAsync = ref.watch(topRatedProductsProvider);
          return topRatedAsync.when(
            data: (topRatedProducts) => _buildHomeContent(topRatedProducts, productsState),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
          );
        },
      ),
      const FavoritesScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white, // Main scaffold background
      appBar: _buildAppBar(cartItemCount),
      body: Container(color: Colors.white, child: screens[_currentIndex]), // Ensure screen background
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: isTablet && cartItemCount > 0 && _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              child: const Icon(Icons.shopping_cart),
            )
          : null,
    );
  }

  AppBar _buildAppBar(int cartItemCount) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: AnimatedCrossFade(
        firstChild: const Text('Tech Haven', 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 22,
            color: Colors.black87,
          )),
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
      iconTheme: const IconThemeData(color: Colors.black87),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black87),
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
              icon: const Icon(Icons.shopping_cart, color: Colors.black87),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            ),
            if (cartItemCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error, 
                    shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text('$cartItemCount', 
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHomeContent(List<Product> topRatedProducts, ProductsState productsState) {
    return RefreshIndicator(
      onRefresh: () async => ref.read(productsProvider.notifier).fetchProducts(refresh: true),
      child: Container(
        color: Colors.white,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSectionTitle('Top Rated Products', () {}),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: topRatedProducts.isEmpty
                    ? const Center(child: Text('No top-rated products found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: topRatedProducts.length,
                        itemBuilder: (_, index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ProductCard(
                            product: topRatedProducts[index],
                            isHorizontal: true,
                          ),
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
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 0.65,
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
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            _buildNavBarItem(Icons.home_outlined, Icons.home_filled, "Home", 0),
            _buildNavBarItem(Icons.favorite_outline, Icons.favorite, "Favorites", 1),
            _buildNavBarItem(Icons.person_outline, Icons.person, "Account", 2),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem(
    IconData outlineIcon,
    IconData filledIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
              child: isSelected
                  ? Icon(
                      filledIcon,
                      key: ValueKey('filled_$index'),
                      size: 28,
                      color: Colors.blueAccent,
                    )
                  : Icon(
                      outlineIcon,
                      key: ValueKey('outline_$index'),
                      size: 26,
                    ),
            ),
          ],
        ),
      ),
      label: label,
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onTap) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, 
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                )),
              TextButton(
                onPressed: onTap,
                child: const Text('See All',
                  style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}