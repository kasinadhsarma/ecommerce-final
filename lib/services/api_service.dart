import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  // Get all products
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List<dynamic> productsJson = json.decode(response.body);
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/category/$category'),
    );

    if (response.statusCode == 200) {
      List<dynamic> productsJson = json.decode(response.body);
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products by category');
    }
  }

  // Get a single product
  Future<Product> getProduct(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product details');
    }
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/categories'),
    );

    if (response.statusCode == 200) {
      List<dynamic> categoriesJson = json.decode(response.body);
      return categoriesJson.map((json) => json.toString()).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
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
  }
}
