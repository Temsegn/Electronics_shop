import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electronics_shop_app/models/product.dart';
import 'package:electronics_shop_app/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ProductsNotifier(apiService);
});

// New provider for top-rated products
final topRatedProductsProvider = FutureProvider<List<Product>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getTopRatedProducts();
});

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final int total;
  final int skip;
  final int limit;
  final bool hasMore;

  ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
    this.total = 0,
    this.skip = 0,
    this.limit = 10,
    this.hasMore = true,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? errorMessage,
    int? total,
    int? skip,
    int? limit,
    bool? hasMore,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ApiService _apiService;

  ProductsNotifier(this._apiService) : super(ProductsState()) {
    fetchProducts();
  }

  Future<void> fetchProducts({bool refresh = false}) async {
    if (refresh) {
      state = ProductsState();
    }

    if (state.isLoading || (!state.hasMore && !refresh)) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _apiService.getProducts(
        limit: state.limit,
        skip: state.skip,
      );

      final List<Product> newProducts = result['products'];
      final int total = result['total'];

      final updatedProducts = refresh
          ? newProducts
          : [...state.products, ...newProducts];

      final newSkip = state.skip + state.limit;
      final hasMore = newSkip < total;

      state = state.copyWith(
        products: updatedProducts,
        isLoading: false,
        total: total,
        skip: newSkip,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      fetchProducts(refresh: true);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final products = await _apiService.searchProducts(query);
      
      state = state.copyWith(
        products: products,
        isLoading: false,
        hasMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void loadMore() {
    if (!state.isLoading && state.hasMore) {
      fetchProducts();
    }
  }
}