import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/common_widgets.dart';
import '../../models/cart_model.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cart = cartProvider.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        automaticallyImplyLeading: false,
        actions: [
          // Clear cart button
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearCartDialog(context),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : _buildCartItems(context, cart, cartProvider),
      bottomNavigationBar:
          cart.items.isEmpty ? null : _buildCheckoutSection(context, cart),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Start Shopping',
            onPressed: () {},
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(
    BuildContext context,
    Cart cart,
    CartProvider cartProvider,
  ) {
    return ListView.builder(
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return _buildCartItemCard(context, item, cartProvider);
      },
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    CartItem item,
    CartProvider cartProvider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 100,
                height: 100,
                child: CachedNetworkImage(
                  imageUrl: item.product.image,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Price
                  Text(
                    CurrencyUtils.formatCurrency(item.product.price),
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quantity controls
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (item.quantity > 1) {
                            cartProvider.updateQuantity(
                              item.product.id,
                              item.quantity - 1,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.remove,
                            size: 20,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          cartProvider.updateQuantity(
                            item.product.id,
                            item.quantity + 1,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Remove item button
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          cartProvider.removeFromCart(item.product.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, Cart cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Order summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                CurrencyUtils.formatCurrency(cart.subtotal),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Delivery fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Fee:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                CurrencyUtils.formatCurrency(cart.deliveryFee),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Discount (if applicable)
          if (cart.discount != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discount:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '-${CurrencyUtils.formatCurrency(cart.discount!)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],

          const Divider(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                CurrencyUtils.formatCurrency(cart.total),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Checkout button
          CustomButton(
            text: 'Proceed to Checkout',
            onPressed: () => _navigateToCheckout(context),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).clearCart();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }
}
