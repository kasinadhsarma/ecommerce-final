import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  List<String> _categories = [];
  List<Product> _featuredProducts = [];
  final Map<String, List<Product>> _productsByCategory = {};
  List<String> _favoriteProductIds = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  List<String> get categories => _categories;
  List<Product> get featuredProducts => _featuredProducts;
  Map<String, List<Product>> get productsByCategory => _productsByCategory;
  List<String> get favoriteProductIds => _favoriteProductIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> get favoriteProducts => _products
      .where((product) => _favoriteProductIds.contains(product.id.toString()))
      .toList();

  // Initialize products and categories
  Future<void> initProducts() async {
    _setLoading(true);

    try {
      await Future.wait([
        _fetchAllProducts(),
        _fetchCategories(),
        _loadFavoriteProducts(),
      ]);

      // Generate featured products (top rated)
      _featuredProducts = List.from(_products)
        ..sort((a, b) => b.rating.rate.compareTo(a.rating.rate));

      if (_featuredProducts.length > 10) {
        _featuredProducts = _featuredProducts.sublist(0, 10);
      }

      // Group products by category
      for (final category in _categories) {
        _productsByCategory[category] =
            _products.where((product) => product.category == category).toList();
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Fetch all products
  Future<void> _fetchAllProducts() async {
    try {
      _products = await _apiService.getAllProducts();
    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
      rethrow;
    }
  }

  // Fetch categories
  Future<void> _fetchCategories() async {
    try {
      _categories = await _apiService.getCategories();
    } catch (e) {
      _error = 'Failed to load categories: ${e.toString()}';
      rethrow;
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    if (_productsByCategory.containsKey(category)) {
      return _productsByCategory[category]!;
    }

    try {
      final products = await _apiService.getProductsByCategory(category);
      _productsByCategory[category] = products;
      notifyListeners();
      return products;
    } catch (e) {
      _error = 'Failed to load category products: ${e.toString()}';
      rethrow;
    }
  }

  // Get product by ID
  Future<Product> getProductById(int id) async {
    final productIndex = _products.indexWhere((product) => product.id == id);

    if (productIndex >= 0) {
      return _products[productIndex];
    }

    try {
      final product = await _apiService.getProduct(id);
      return product;
    } catch (e) {
      _error = 'Failed to load product details: ${e.toString()}';
      rethrow;
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      return await _apiService.searchProducts(query);
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
      rethrow;
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String productId) async {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }

    notifyListeners();
    await _saveFavoriteProducts();
  }

  // Load favorite products from shared preferences
  Future<void> _loadFavoriteProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorites');

      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        _favoriteProductIds = decoded.map((id) => id.toString()).toList();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // Save favorite products to shared preferences
  Future<void> _saveFavoriteProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(_favoriteProductIds);

      await prefs.setString('favorites', favoritesJson);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
