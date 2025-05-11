import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../utils/app_utils.dart' as app_utils;
import '../../widgets/common_widgets.dart';
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => OrderHistoryScreenState();
}

class OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.user != null) {
      await orderProvider.loadOrders(authProvider.user!.id);
    }
  }

  List<Order> _getFilteredOrders(List<Order> orders) {
    if (_selectedFilter == 'All') {
      return orders;
    }

    final orderStatus = OrderStatus.values.firstWhere(
      (status) => status.toString().split('.').last == _selectedFilter,
      orElse: () => OrderStatus.pending,
    );

    return orders.where((order) => order.status == orderStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    if (!authProvider.isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Text('You need to be logged in to view your orders.'),
        ),
      );
    }

    final orders = orderProvider.orders;
    final filteredOrders = _getFilteredOrders(orders);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Colors.deepPurple.shade100,
                      checkmarkColor: Colors.deepPurple,
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter
                            ? Colors.deepPurple
                            : Colors.black,
                        fontWeight: _selectedFilter == filter
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Order list
          Expanded(
            child: orderProvider.isLoading
                ? const LoadingIndicator(message: 'Loading orders...')
                : orders.isEmpty
                    ? _buildEmptyOrdersState()
                    : filteredOrders.isEmpty
                        ? _buildNoFilteredOrdersState()
                        : RefreshIndicator(
                            onRefresh: _loadOrders,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];
                                return _buildOrderCard(context, order);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    Color statusColor;

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        break;
      case OrderStatus.confirmed:
        statusColor = Colors.blue;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => _navigateToOrderDetails(context, order),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(4, 12)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    app_utils.DateTimeUtils.formatDate(order.orderDate),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Items summary
              Text(
                '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),

              // Show first 2 items
              ...order.items.take(2).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    '${item.quantity}x ${item.product.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),

              // Show "and more" if there are more items
              if (order.items.length > 2)
                Text(
                  'and ${order.items.length - 2} more...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),

              const Divider(height: 16),

              // Total and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${app_utils.CurrencyUtils.formatCurrency(order.totalAmount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.toString().split('.').last,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Reorder button for completed orders
              if (order.status == OrderStatus.delivered) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.replay),
                      label: const Text('Reorder'),
                      onPressed: () => _reorder(context, order),
                    ),
                  ],
                ),
              ]

              // Cancel button for pending orders
              else if (order.status == OrderStatus.pending) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Cancel Order',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => _cancelOrder(context, order),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your order history will appear here',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Start Shopping',
            onPressed: () {
              Navigator.pop(context);
            },
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildNoFilteredOrdersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.filter_alt_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No $_selectedFilter Orders',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any $_selectedFilter orders',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Show All Orders',
            onPressed: () {
              setState(() {
                _selectedFilter = 'All';
              });
            },
            width: 200,
          ),
        ],
      ),
    );
  }

  void _navigateToOrderDetails(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(order: order),
      ),
    );
  }

  void _reorder(BuildContext context, Order order) {
    // Implement reorder functionality
    app_utils.showSnackBar(
      context,
      'Reorder functionality will be implemented soon!',
    );
  }

  void _cancelOrder(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final orderProvider = Provider.of<OrderProvider>(
                context,
                listen: false,
              );

              final success = await orderProvider.cancelOrder(order.id);

              if (!context.mounted) {
                return; // Corrected: check parameter context's mounted status
              }

              if (success) {
                // No need for another mounted check here as it's synchronous after the await guard
                app_utils.showSnackBar(
                  context,
                  'Order cancelled successfully',
                );
              } else {
                // No need for another mounted check here
                app_utils.showSnackBar(
                  context,
                  'Failed to cancel order. Please try again.',
                  isError: true,
                );
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
