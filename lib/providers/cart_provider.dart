import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  Cart _cart = Cart();

  Cart get cart => _cart;

  int get itemCount => _cart.items.fold(0, (sum, item) => sum + item.quantity);

  // Load cart from shared preferences
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart');

      if (cartJson != null) {
        _cart = Cart.fromJson(json.decode(cartJson));
        notifyListeners();
      }
    } catch (e) {
      // Handle errors
      debugPrint('Error loading cart: $e');
    }
  }

  // Save cart to shared preferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_cart.toJson());

      await prefs.setString('cart', cartJson);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  // Add a product to the cart
  void addToCart(Product product,
      {int quantity = 1, Map<String, dynamic>? customizations}) {
    // Check if the product is already in the cart
    final existingIndex =
        _cart.items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Update quantity if product already exists
      final existingItem = _cart.items[existingIndex];
      final updatedItems = List<CartItem>.from(_cart.items);

      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
        customizations: customizations ?? existingItem.customizations,
      );

      _cart = _cart.copyWith(items: updatedItems);
    } else {
      // Add new item to cart
      final updatedItems = List<CartItem>.from(_cart.items)
        ..add(CartItem(
          product: product,
          quantity: quantity,
          customizations: customizations,
        ));

      _cart = _cart.copyWith(items: updatedItems);
    }

    notifyListeners();
    _saveCart();
  }

  // Update cart item quantity
  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final updatedItems = _cart.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    _cart = _cart.copyWith(items: updatedItems);
    notifyListeners();
    _saveCart();
  }

  // Remove item from cart
  void removeFromCart(int productId) {
    final updatedItems =
        _cart.items.where((item) => item.product.id != productId).toList();

    _cart = _cart.copyWith(items: updatedItems);
    notifyListeners();
    _saveCart();
  }

  // Clear cart
  void clearCart() {
    _cart = Cart();
    notifyListeners();
    _saveCart();
  }

  // Apply promo code
  void applyPromoCode(String promoCode, double discount) {
    _cart = _cart.copyWith(
      promoCode: promoCode,
      discount: discount,
    );

    notifyListeners();
    _saveCart();
  }

  // Remove promo code
  void removePromoCode() {
    _cart = _cart.copyWith(
      promoCode: null,
      discount: null,
    );

    notifyListeners();
    _saveCart();
  }

  // Set delivery fee
  void setDeliveryFee(double fee) {
    _cart = _cart.copyWith(deliveryFee: fee);
    notifyListeners();
    _saveCart();
  }
}
