import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../utils/app_utils.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/order_provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(4, 12)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStatusCard(context),
            const SizedBox(height: 20),
            _buildItemsCard(context),
            const SizedBox(height: 20),
            _buildDeliveryDetailsCard(context),
            const SizedBox(height: 20),
            _buildPaymentDetailsCard(context),
            const SizedBox(height: 20),
            _buildLoyaltyDetails(context),
            const SizedBox(height: 30),

            // Order actions
            if (order.status == OrderStatus.pending)
              _buildCancelOrderButton(context),
            if (order.status == OrderStatus.delivered)
              _buildReorderButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Order Status Timeline
            _buildOrderTimeline(context),

            const Divider(height: 32),

            // Order Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Ordered on ${DateTimeUtils.formatDate(order.orderDate)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Scheduled Date (if any)
            if (order.scheduledDate != null) ...[
              Row(
                children: [
                  const Icon(Icons.event, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${order.deliveryMethod == DeliveryMethod.pickup ? 'Pickup' : 'Delivery'} scheduled for ${DateTimeUtils.formatDateTime(order.scheduledDate!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTimeline(BuildContext context) {
    final List<OrderStatus> statusSequence = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      order.deliveryMethod == DeliveryMethod.pickup
          ? OrderStatus.readyForPickup
          : OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    final currentStatusIndex = statusSequence.indexOf(order.status);

    // If order is cancelled, show a different UI
    if (order.status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cancel,
              color: Colors.red,
            ),
            const SizedBox(width: 12),
            const Text(
              'Order Cancelled',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(statusSequence.length, (index) {
        final isCompleted = index <= currentStatusIndex;
        final isCurrent = index == currentStatusIndex;

        return Expanded(
          child: Column(
            children: [
              // Status dot
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: Colors.green, width: 3)
                      : null,
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),

              // Line between dots
              if (index < statusSequence.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    height: 3,
                    color: index < currentStatusIndex
                        ? Colors.green
                        : Colors.grey.shade300,
                  ),
                ),

              const SizedBox(height: 8),

              // Status text
              Text(
                _getStatusLabel(statusSequence[index]),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isCurrent ? Colors.green : Colors.grey.shade700,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Widget _buildItemsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Item list
            ...order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.network(
                          item.product.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${CurrencyUtils.formatCurrency(item.product.price)} × ${item.quantity}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Item subtotal
                    Text(
                      CurrencyUtils.formatCurrency(
                          item.product.price * item.quantity),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: 24),

            // Order summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text(CurrencyUtils.formatCurrency(order.totalAmount)),
              ],
            ),
            const SizedBox(height: 8),

            // If loyalty points were used, show the discount
            if (order.loyaltyPointsUsed > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Loyalty Discount'),
                  Text(
                    '- ${CurrencyUtils.formatCurrency(order.loyaltyPointsUsed / 10)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Total amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  CurrencyUtils.formatCurrency(order.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDetailsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Delivery method
            Row(
              children: [
                Icon(
                  order.deliveryMethod == DeliveryMethod.pickup
                      ? Icons.store
                      : Icons.delivery_dining,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  order.deliveryMethod == DeliveryMethod.pickup
                      ? 'In-Store Pickup'
                      : 'Home Delivery',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Delivery address (for delivery orders)
            if (order.deliveryMethod == DeliveryMethod.delivery &&
                order.deliveryAddress != null) ...[
              const Text(
                'Delivery Address:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(order.deliveryAddress!.address),
              Text(
                  '${order.deliveryAddress!.city}, ${order.deliveryAddress!.zipCode}'),
              if (order.deliveryAddress!.additionalInfo != null &&
                  order.deliveryAddress!.additionalInfo!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Additional Info: ${order.deliveryAddress!.additionalInfo}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],

            // Pickup details (for pickup orders)
            if (order.deliveryMethod == DeliveryMethod.pickup) ...[
              const Text(
                'Pickup from:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text('Main Store'),
              const Text('123 Shopping Street, Retail City, RC 12345'),
              const SizedBox(height: 8),
              const Text(
                'Please bring your order ID and a valid ID for pickup.',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Payment method
            Row(
              children: [
                Icon(_getPaymentIcon(order.paymentMethod)),
                const SizedBox(width: 8),
                Text(
                  order.paymentMethod ?? 'Cash on Delivery',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Payment ID if available
            if (order.paymentId != null && order.paymentId!.isNotEmpty) ...[
              Row(
                children: [
                  const Text('Transaction ID: '),
                  const SizedBox(width: 4),
                  Text(
                    order.paymentId!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            // Amount paid
            Row(
              children: [
                const Text('Amount paid: '),
                const SizedBox(width: 4),
                Text(
                  CurrencyUtils.formatCurrency(order.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String? paymentMethod) {
    if (paymentMethod == null) {
      return Icons.money;
    }

    final method = paymentMethod.toLowerCase();

    if (method.contains('credit') || method.contains('card')) {
      return Icons.credit_card;
    } else if (method.contains('paypal')) {
      return Icons.account_balance_wallet;
    } else if (method.contains('apple')) {
      return Icons.apple;
    } else if (method.contains('google')) {
      return Icons.g_mobiledata;
    } else {
      return Icons.payment;
    }
  }

  Widget _buildLoyaltyDetails(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loyalty Program',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Points earned
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Points earned: ${order.loyaltyPointsEarned}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),

            // Points used (if any)
            if (order.loyaltyPointsUsed > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.redeem, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Points redeemed: ${order.loyaltyPointsUsed}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Info about loyalty program
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Earn 1 point for every \$1 spent. 10 points = \$1 discount on future orders.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelOrderButton(BuildContext context) {
    return CustomButton(
      text: 'Cancel Order',
      icon: Icons.cancel_outlined,
      backgroundColor: Colors.red,
      onPressed: () => _confirmCancelOrder(context),
    );
  }

  Widget _buildReorderButton(BuildContext context) {
    return CustomButton(
      text: 'Reorder',
      icon: Icons.replay,
      onPressed: () => _reorder(context),
    );
  }

  void _confirmCancelOrder(BuildContext context) {
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

              if (success && context.mounted) {
                showSnackBar(
                  context,
                  'Order cancelled successfully',
                );

                // Pop back to order history
                Navigator.pop(context);
              } else if (context.mounted) {
                showSnackBar(
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

  void _reorder(BuildContext context) {
    // Implement reorder functionality
    showSnackBar(
      context,
      'Reorder functionality will be implemented soon!',
    );
  }
}

void showSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}
