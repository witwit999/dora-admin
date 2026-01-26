import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dora_admin/l10n/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/product_model.dart';
import '../../shared/providers/products_provider.dart';
import '../../shared/widgets/main_scaffold.dart';
import 'package:intl/intl.dart';

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load products when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(productsProvider);
      // Only load if not already loaded
      if (state.products.isEmpty && !state.isLoading) {
        ref.read(productsProvider.notifier).loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger load more when user is near the bottom (200 pixels from end)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsProvider.notifier).loadMore();
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        ref.read(productsProvider.notifier).clearSearch();
      }
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      ref.read(productsProvider.notifier).clearSearch();
    } else {
      ref.read(productsProvider.notifier).search(query);
    }
  }

  Future<void> _handleRefresh() async {
    await ref.read(productsProvider.notifier).refresh();
  }

  void _showDeleteDialog(Product product) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.productsDeleteTitle),
        content: Text(l10n.productsDeleteMessage(product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteProduct(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await ref
        .read(productsProvider.notifier)
        .deleteProduct(product.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productsDeleteSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = ref.read(productsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? l10n.productsDeleteFailed),
          backgroundColor: AppTheme.errorColor,
          action: SnackBarAction(
            label: l10n.commonRetry,
            textColor: Colors.white,
            onPressed: () => _deleteProduct(product),
          ),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _handleRefresh,
        ),
      ),
    );
  }

  // Calculate responsive grid parameters based on screen width
  ({int crossAxisCount, double childAspectRatio}) _getGridParams(double width) {
    if (width < 400) {
      // Small phones
      return (crossAxisCount: 2, childAspectRatio: 0.65);
    } else if (width < 600) {
      // Large phones
      return (crossAxisCount: 2, childAspectRatio: 0.72);
    } else if (width < 900) {
      // Tablets portrait
      return (crossAxisCount: 3, childAspectRatio: 0.75);
    } else if (width < 1200) {
      // Tablets landscape / Small desktops
      return (crossAxisCount: 4, childAspectRatio: 0.78);
    } else {
      // Large desktops
      return (crossAxisCount: 5, childAspectRatio: 0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final products = productsState.products;
    final l10n = AppLocalizations.of(context)!;

    // Show error snackbar if there's an error and not in loading state
    ref.listen<ProductsState>(productsProvider, (previous, next) {
      if (next.error != null &&
          !next.isLoading &&
          !next.isLoadingMore &&
          !next.isDeleting) {
        _showErrorSnackBar(next.error!);
        ref.read(productsProvider.notifier).clearError();
      }
    });

    return Stack(
      children: [
        MainScaffold(
          title: productsState.isSearchMode
              ? l10n.productsSearchResults
              : l10n.productsTitle,
          actions: [
            // Search toggle button
            IconButton(
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
              tooltip: _isSearchVisible
                  ? l10n.productsCloseSearchTooltip
                  : l10n.productsSearchTooltip,
            ),
          ],
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push(AppConstants.productNewRoute),
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              // Search bar
              if (_isSearchVisible)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surface,
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.productsSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(productsProvider.notifier)
                                    .clearSearch();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    onChanged: (value) {
                      setState(() {}); // Rebuild to show/hide clear button
                    },
                    onSubmitted: _performSearch,
                    textInputAction: TextInputAction.search,
                  ),
                ),

              // Search info bar
              if (productsState.isSearchMode &&
                  productsState.searchQuery != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.productsSearchResultsCount(
                            productsState.totalItems,
                            productsState.searchQuery!,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          ref.read(productsProvider.notifier).clearSearch();
                        },
                        child: Text(l10n.productsClear),
                      ),
                    ],
                  ),
                ),

              // Products content
              Expanded(child: _buildContent(productsState, products)),
            ],
          ),
        ),

        // Loading overlay for deletion
        if (productsState.isDeleting)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(l10n.productsDeletingProgress),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(ProductsState productsState, List<Product> products) {
    final l10n = AppLocalizations.of(context)!;

    // Initial loading state
    if (productsState.isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state - wrap with RefreshIndicator for pull to refresh
    if (products.isEmpty && !productsState.isLoading) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        productsState.isSearchMode
                            ? Icons.search_off
                            : Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        productsState.isSearchMode
                            ? l10n.productsNoProductsFound
                            : l10n.productsNoProductsYet,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        productsState.isSearchMode
                            ? l10n.productsTryDifferentSearch
                            : l10n.productsAddFirstProduct,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.productsPullToRefresh,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      if (productsState.error != null) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _handleRefresh,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.commonRetry),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Products grid with infinite scroll
    return LayoutBuilder(
      builder: (context, constraints) {
        final params = _getGridParams(constraints.maxWidth);

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: params.crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: params.childAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = products[index];
                    return _ProductCard(
                      product: product,
                      onEdit: () {
                        context.push('/products/${product.id}/edit');
                      },
                      onDelete: () => _showDeleteDialog(product),
                    );
                  }, childCount: products.length),
                ),
              ),

              // Loading more indicator
              if (productsState.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),

              // End of list indicator
              if (!productsState.hasMore && products.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        l10n.productsEndOfList,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.currency(symbol: 'IQD', decimalDigits: 2);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image section - takes most of the space
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.grey.shade200,
                  child: product.imageSource != null
                      ? Image.network(
                          product.imageSource!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const _ImageSkeletonLoader();
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),

              // Product info - compact section
              Flexible(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (product.price != null)
                        Text(
                          priceFormat.format(product.price),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Action buttons overlay on top right of image
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    color: AppTheme.primaryColor,
                    onPressed: onEdit,
                    tooltipKey: 'edit',
                  ),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    color: AppTheme.errorColor,
                    onPressed: onDelete,
                    tooltipKey: 'delete',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends ConsumerWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltipKey;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltipKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tooltip = tooltipKey == 'edit'
        ? l10n.productsEditTooltip
        : l10n.productsDeleteTooltip;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

/// Skeleton loading effect for images
class _ImageSkeletonLoader extends StatefulWidget {
  const _ImageSkeletonLoader();

  @override
  State<_ImageSkeletonLoader> createState() => _ImageSkeletonLoaderState();
}

class _ImageSkeletonLoaderState extends State<_ImageSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade50,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 40,
              color: Colors.grey.shade300,
            ),
          ),
        );
      },
    );
  }
}
