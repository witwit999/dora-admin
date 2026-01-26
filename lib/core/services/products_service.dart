import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../../shared/models/product_model.dart';
import '../../shared/models/pagination_model.dart';
import 'api_service.dart';

/// Products Service for product-related API operations
class ProductsService {
  final ApiService _apiService;

  ProductsService(this._apiService);

  /// Get paginated list of products
  Future<PaginatedProducts> getProducts({int page = 1, int limit = 20}) async {
    final response = await _apiService.get(
      ApiConfig.products,
      queryParameters: {'page': page, 'limit': limit},
    );

    return PaginatedProducts.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create a new product with image
  Future<Product> createProduct({
    required String name,
    required String description,
    double? price,
    required File image,
    bool? isFeatured,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      if (price != null) 'price': price,
      if (isFeatured != null) 'featured': isFeatured,
      'image': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });

    final response = await _apiService.post(
      ApiConfig.products,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update an existing product (without image)
  Future<Product> updateProduct({
    required int id,
    required String name,
    required String description,
    double? price,
    bool isFeatured = false,
  }) async {
    final response = await _apiService.put(
      '${ApiConfig.products}/$id',
      data: {
        'name': name,
        'description': description,
        'price': price,
        'featured': isFeatured,
      },
    );

    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update product image
  Future<Product> updateProductImage({
    required int id,
    required File image,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });

    final response = await _apiService.put(
      '${ApiConfig.products}/$id/image',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete a product
  Future<void> deleteProduct(int id) async {
    await _apiService.delete('${ApiConfig.products}/$id');
  }

  /// Search products by ID or name query
  Future<PaginatedProducts> searchProducts({
    int? id,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};

    if (id != null) {
      queryParameters['id'] = id;
    }
    if (query != null && query.isNotEmpty) {
      queryParameters['q'] = query;
    }

    final response = await _apiService.get(
      ApiConfig.productsSearch,
      queryParameters: queryParameters,
    );

    return PaginatedProducts.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get a single product by ID
  Future<Product?> getProductById(int id) async {
    try {
      final result = await searchProducts(id: id, limit: 1);
      if (result.items.isNotEmpty) {
        return Product.fromJson(result.items.first as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
