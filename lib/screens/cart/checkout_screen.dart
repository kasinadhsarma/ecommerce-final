import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/loyalty_provider.dart';
import '../../models/order_model.dart';
import '../../utils/app_utils.dart';
import '../../widgets/common_widgets.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  DeliveryMethod _deliveryMethod = DeliveryMethod.delivery;
  String _paymentMethod = 'Credit Card';
  DateTime? _scheduledDate;
  bool _useRewardPoints = false;
  int _rewardPointsToUse = 0;

  final List<String> _paymentMethods = [
    'Credit Card',
    'Apple Pay',
    'Google Pay',
    'Cash on Delivery',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final loyaltyProvider = Provider.of<LoyaltyProvider>(context);

    final cart = cartProvider.cart;
    final user = authProvider.user;
    final userPoints =
        user != null ? loyaltyProvider.getUserPoints(user.id) : 0;

    // Calculate discount from loyalty points
    final pointsDiscount = _useRewardPoints ? (_rewardPointsToUse / 10) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery method
              const Text(
                'Delivery Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: RadioListTile<DeliveryMethod>(
                      title: const Text('Delivery'),
                      value: DeliveryMethod.delivery,
                      groupValue: _deliveryMethod,
                      onChanged: (value) {
                        setState(() {
                          _deliveryMethod = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<DeliveryMethod>(
                      title: const Text('Pickup'),
                      value: DeliveryMethod.pickup,
                      groupValue: _deliveryMethod,
                      onChanged: (value) {
                        setState(() {
                          _deliveryMethod = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Delivery address (only for delivery)
              if (_deliveryMethod == DeliveryMethod.delivery) ...[
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  label: 'Address',
                  hint: 'Enter your address',
                  controller: _addressController,
                  validator: Validators.validateAddress,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'City',
                        hint: 'Enter your city',
                        controller: _cityController,
                        validator: Validators.validateName,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Zip Code',
                        hint: 'Enter zip code',
                        controller: _zipCodeController,
                        keyboardType: TextInputType.number,
                        validator: Validators.validateZipCode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Additional Information (Optional)',
                  hint: 'Apartment number, building, etc.',
                  controller: _additionalInfoController,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
              ],

              // Schedule time
              const Text(
                'Schedule Order',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              ListTile(
                title: _scheduledDate == null
                    ? const Text('Deliver as soon as possible')
                    : Text(
                        'Scheduled for: ${DateTimeUtils.formatDateTime(_scheduledDate!)}',
                      ),
                trailing: TextButton(
                  child: Text(_scheduledDate == null ? 'Schedule' : 'Change'),
                  onPressed: () => _selectDateTime(context),
                ),
              ),
              const SizedBox(height: 16),

              // Payment method
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Loyalty points
              if (userPoints > 0) ...[
                const Text(
                  'Loyalty Points',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _useRewardPoints,
                      onChanged: (value) {
                        setState(() {
                          _useRewardPoints = value!;
                        });
                      },
                    ),
                    const Text('Use reward points'),
                  ],
                ),
                if (_useRewardPoints) ...[
                  Slider(
                    value: _rewardPointsToUse.toDouble(),
                    min: 0,
                    max: userPoints.toDouble(),
                    divisions: userPoints > 100 ? 100 : userPoints,
                    label: _rewardPointsToUse.toString(),
                    onChanged: (value) {
                      setState(() {
                        _rewardPointsToUse = value.toInt();
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0 points'),
                      Text('$userPoints points'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Using $_rewardPointsToUse points for a discount of ${CurrencyUtils.formatCurrency(pointsDiscount)}',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // Order summary
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Items summary
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                        '${item.quantity} x ${CurrencyUtils.formatCurrency(item.product.price)}'),
                    trailing: Text(
                      CurrencyUtils.formatCurrency(item.totalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              const Divider(),

              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:'),
                  Text(
                    CurrencyUtils.formatCurrency(cart.subtotal),
                    style: const TextStyle(
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
                  const Text('Delivery Fee:'),
                  Text(
                    CurrencyUtils.formatCurrency(cart.deliveryFee),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Loyalty points discount
              if (_useRewardPoints && _rewardPointsToUse > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Points Discount:'),
                    Text(
                      '-${CurrencyUtils.formatCurrency(pointsDiscount)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],

              // Promo discount
              if (cart.discount != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Promo Discount:'),
                    Text(
                      '-${CurrencyUtils.formatCurrency(cart.discount!)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],

              const Divider(),

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
                    CurrencyUtils.formatCurrency(
                      cart.total - pointsDiscount,
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Place order button
              CustomButton(
                text: 'Place Order',
                onPressed: () => _placeOrder(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (pickedDate != null) {
      // Check if widget is still mounted before showing time picker
      if (!mounted) return;

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _scheduledDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (_deliveryMethod == DeliveryMethod.delivery &&
        !_formKey.currentState!.validate()) {
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final loyaltyProvider =
        Provider.of<LoyaltyProvider>(context, listen: false);

    final user = authProvider.user;

    if (user == null) {
      showSnackBar(
        context,
        'You need to be logged in to place an order',
        isError: true,
      );
      return;
    }

    OrderAddress? deliveryAddress;
    if (_deliveryMethod == DeliveryMethod.delivery) {
      deliveryAddress = OrderAddress(
        address: _addressController.text,
        city: _cityController.text,
        zipCode: _zipCodeController.text,
        additionalInfo: _additionalInfoController.text,
      );
    }

    try {
      // Use loyalty points if selected
      if (_useRewardPoints && _rewardPointsToUse > 0) {
        await loyaltyProvider.usePoints(user.id, _rewardPointsToUse);
      }

      // Create the order
      final newOrder = await orderProvider.createOrder(
        userId: user.id,
        cart: cartProvider.cart,
        deliveryMethod: _deliveryMethod,
        deliveryAddress: deliveryAddress,
        scheduledDate: _scheduledDate,
        paymentMethod: _paymentMethod,
        loyaltyPointsUsed: _useRewardPoints ? _rewardPointsToUse : 0,
      );

      // Clear the cart
      cartProvider.clearCart();

      // Add loyalty points earned from this order
      await loyaltyProvider.addPoints(user.id, newOrder.loyaltyPointsEarned);

      // Navigate to success screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(order: newOrder),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          'Failed to place order: ${e.toString()}',
          isError: true,
        );
      }
    }
  }
}
