import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../utils/network_error_handler.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  // Use a different URL for web to work around CORS issues if needed
  static String getBaseUrl() {
    if (kIsWeb) {
      // If you've set up a CORS proxy for local development
      // return 'http://localhost:3000/api';
      return baseUrl; // Use direct URL if CORS is properly configured
    }
    return baseUrl;
  }

  // Get all products
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await NetworkErrorHandler.safeHttpRequest(
        () => http.get(Uri.parse('${getBaseUrl()}/products')),
      );

      List<dynamic> productsJson = json.decode(response.body);
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } on NetworkError catch (e) {
      debugPrint('Network error fetching products: $e');
      throw Exception('Failed to load products: ${e.message}');
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await NetworkErrorHandler.safeHttpRequest(
        () => http.get(
          Uri.parse('${getBaseUrl()}/products/category/$category'),
        ),
      );

      List<dynamic> productsJson = json.decode(response.body);
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } on NetworkError catch (e) {
      debugPrint('Network error fetching products by category: $e');
      throw Exception('Failed to load products by category: ${e.message}');
    }
  }

  // Get a single product
  Future<Product> getProduct(int id) async {
    try {
      final response = await NetworkErrorHandler.safeHttpRequest(
        () => http.get(Uri.parse('${getBaseUrl()}/products/$id')),
      );

      return Product.fromJson(json.decode(response.body));
    } on NetworkError catch (e) {
      debugPrint('Network error fetching product details: $e');
      throw Exception('Failed to load product details: ${e.message}');
    }
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    try {
      final response = await NetworkErrorHandler.safeHttpRequest(
        () => http.get(Uri.parse('${getBaseUrl()}/products/categories')),
      );

      List<dynamic> categoriesJson = json.decode(response.body);
      return categoriesJson.map((json) => json.toString()).toList();
    } on NetworkError catch (e) {
      debugPrint('Network error fetching categories: $e');
      throw Exception('Failed to load categories: ${e.message}');
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final products = await getAllProducts();

      return products.where((product) {
        final titleMatch =
            product.title.toLowerCase().contains(query.toLowerCase());
        final descriptionMatch =
            product.description.toLowerCase().contains(query.toLowerCase());
        final categoryMatch =
            product.category.toLowerCase().contains(query.toLowerCase());

        return titleMatch || descriptionMatch || categoryMatch;
      }).toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      throw Exception('Failed to search products: $e');
    }
  }
}
