import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order_model.dart';
import '../models/cart_model.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize orders
  Future<void> loadOrders(String userId) async {
    _setLoading(true);

    try {
      await _loadOrdersFromStorage(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Load orders from storage
  Future<void> _loadOrdersFromStorage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('orders_$userId');

      if (ordersJson != null) {
        final List<dynamic> decodedOrders = json.decode(ordersJson);
        _orders = decodedOrders
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();

        // Sort orders by date (newest first)
        _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
      _orders = [];
    }
  }

  // Save orders to storage
  Future<void> _saveOrdersToStorage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson =
          json.encode(_orders.map((order) => order.toJson()).toList());

      await prefs.setString('orders_$userId', ordersJson);
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }

  // Create a new order
  Future<Order> createOrder({
    required String userId,
    required Cart cart,
    required DeliveryMethod deliveryMethod,
    OrderAddress? deliveryAddress,
    DateTime? scheduledDate,
    String? paymentMethod,
    String? paymentId,
    int loyaltyPointsUsed = 0,
  }) async {
    _setLoading(true);

    try {
      // Generate a unique order ID
      final orderId =
          'ORD-${DateTime.now().millisecondsSinceEpoch}-${_orders.length + 1}';

      // Calculate loyalty points earned (1 point per dollar spent)
      final loyaltyPointsEarned = cart.total.floor();

      final newOrder = Order(
        id: orderId,
        userId: userId,
        items: List.from(cart.items),
        totalAmount: cart.total,
        orderDate: DateTime.now(),
        scheduledDate: scheduledDate,
        status: OrderStatus.pending,
        deliveryMethod: deliveryMethod,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        paymentId: paymentId,
        loyaltyPointsEarned: loyaltyPointsEarned,
        loyaltyPointsUsed: loyaltyPointsUsed,
      );

      _orders.add(newOrder);
      await _saveOrdersToStorage(userId);

      notifyListeners();
      _setLoading(false);

      return newOrder;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);

    if (orderIndex >= 0) {
      final updatedOrder = _orders[orderIndex].copyWith(status: status);
      _orders[orderIndex] = updatedOrder;

      notifyListeners();
      await _saveOrdersToStorage(updatedOrder.userId);
    }
  }

  // Get order by ID
  Order? getOrderById(String orderId) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);

    if (orderIndex >= 0) {
      return _orders[orderIndex];
    }

    return null;
  }

  // Get recent orders
  List<Order> getRecentOrders({int limit = 5}) {
    final sortedOrders = List<Order>.from(_orders)
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

    if (sortedOrders.length <= limit) {
      return sortedOrders;
    }

    return sortedOrders.sublist(0, limit);
  }

  // Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);

    if (orderIndex >= 0) {
      final order = _orders[orderIndex];

      // Only allow cancellation if order is pending
      if (order.status == OrderStatus.pending) {
        final updatedOrder = order.copyWith(status: OrderStatus.cancelled);
        _orders[orderIndex] = updatedOrder;

        notifyListeners();
        await _saveOrdersToStorage(order.userId);
        return true;
      }
    }

    return false;
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
