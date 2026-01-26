import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/products_service.dart';
import '../../core/services/service_providers.dart';
import '../models/product_model.dart';

/// Products state with pagination and search support
class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isDeleting;
  final String? error;

  // Pagination
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  // Search
  final String? searchQuery;
  final bool isSearchMode;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isDeleting = false,
    this.error,
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalItems = 0,
    this.hasMore = true,
    this.searchQuery,
    this.isSearchMode = false,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isDeleting,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
    String? searchQuery,
    bool? isSearchMode,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearchMode: isSearchMode ?? this.isSearchMode,
    );
  }
}

/// Products notifier with API integration
class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductsService _productsService;
  static const int _pageSize = 20;

  ProductsNotifier(this._productsService) : super(const ProductsState());

  /// Internal method to fetch products from API
  Future<void> _fetchProducts() async {
    try {
      final result = await _productsService.getProducts(
        page: 1,
        limit: _pageSize,
      );
      final products = result.items
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        products: products,
        isLoading: false,
        currentPage: result.page.page,
        totalPages: result.page.totalPages,
        totalItems: result.page.totalItems,
        hasMore: result.page.hasMore,
        isSearchMode: false,
        searchQuery: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load products (first page) - public method with guard
  Future<void> loadProducts() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      isSearchMode: false,
      searchQuery: null,
    );

    await _fetchProducts();
  }

  /// Load more products (next page) for infinite scroll
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final nextPage = state.currentPage + 1;

      final result = state.isSearchMode && state.searchQuery != null
          ? await _productsService.searchProducts(
              query: state.searchQuery,
              page: nextPage,
              limit: _pageSize,
            )
          : await _productsService.getProducts(
              page: nextPage,
              limit: _pageSize,
            );

      final newProducts = result.items
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        products: [...state.products, ...newProducts],
        isLoadingMore: false,
        currentPage: result.page.page,
        totalPages: result.page.totalPages,
        totalItems: result.page.totalItems,
        hasMore: result.page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  /// Refresh products list (reload from first page)
  Future<void> refresh() async {
    // Don't refresh if already loading
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    if (state.isSearchMode && state.searchQuery != null) {
      await _fetchSearchProducts(state.searchQuery!);
    } else {
      await _fetchProducts();
    }
  }

  /// Internal method to fetch search results
  Future<void> _fetchSearchProducts(String query) async {
    try {
      final result = await _productsService.searchProducts(
        query: query.trim(),
        page: 1,
        limit: _pageSize,
      );

      final products = result.items
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        products: products,
        isLoading: false,
        currentPage: result.page.page,
        totalPages: result.page.totalPages,
        totalItems: result.page.totalItems,
        hasMore: result.page.hasMore,
        isSearchMode: true,
        searchQuery: query.trim(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Search products by name
  Future<void> search(String query) async {
    if (state.isLoading) return;

    if (query.trim().isEmpty) {
      await clearSearch();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      isSearchMode: true,
      searchQuery: query.trim(),
    );

    await _fetchSearchProducts(query);
  }

  /// Clear search and reload all products
  Future<void> clearSearch() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      isSearchMode: false,
      searchQuery: null,
      error: null,
    );
    await _fetchProducts();
  }

  /// Create a new product
  Future<bool> createProduct({
    required String name,
    required String description,
    double? price,
    required File image,
    bool isFeatured = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _productsService.createProduct(
        name: name,
        description: description,
        price: price,
        image: image,
        isFeatured: isFeatured,
      );

      // Fetch fresh data from server
      await _fetchProducts();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update an existing product
  Future<bool> updateProduct({
    required int id,
    required String name,
    required String description,
    double? price,
    File? newImage,
    bool? isFeatured,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Update product details
      await _productsService.updateProduct(
        id: id,
        name: name,
        description: description,
        price: price,
        isFeatured: isFeatured ?? false,
      );

      // Update image if a new one was provided
      if (newImage != null) {
        await _productsService.updateProductImage(id: id, image: newImage);
      }

      // Fetch fresh data from server
      await _fetchProducts();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(int productId) async {
    state = state.copyWith(isDeleting: true, error: null);

    try {
      await _productsService.deleteProduct(productId);

      // Remove the product from local state immediately for better UX
      state = state.copyWith(
        products: state.products.where((p) => p.id != productId).toList(),
        isDeleting: false,
      );

      // Refresh the list in background to get fresh data from server
      loadProducts();
      return true;
    } catch (e) {
      state = state.copyWith(isDeleting: false, error: e.toString());
      return false;
    }
  }

  /// Get a product by ID from current state
  Product? getProductById(int id) {
    try {
      return state.products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Fetch a product by ID from API
  Future<Product?> fetchProductById(int id) async {
    try {
      return await _productsService.getProductById(id);
    } catch (e) {
      return null;
    }
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Products provider with dependency injection
final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>(
  (ref) {
    final productsService = ref.read(productsServiceProvider);
    return ProductsNotifier(productsService);
  },
);
