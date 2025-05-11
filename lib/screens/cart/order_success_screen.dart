import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../utils/app_utils.dart';
import '../../widgets/common_widgets.dart';
import 'package:confetti/confetti.dart';
import '../home_screen.dart';
import '../profile/order_history_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final Order order;

  const OrderSuccessScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  _OrderSuccessScreenState createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Start confetti animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToHome();
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Confetti animation
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  colors: const [
                    Colors.deepPurple,
                    Colors.purple,
                    Colors.deepPurpleAccent,
                    Colors.purpleAccent,
                    Colors.white,
                  ],
                  numberOfParticles: 50,
                ),
              ),

              // Success content
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    // Success icon
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 100,
                    ),
                    const SizedBox(height: 24),

                    // Success message
                    const Text(
                      'Order Placed Successfully!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Your order has been placed successfully. You will receive a confirmation email shortly.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Order info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order ID
                          Row(
                            children: [
                              const Text(
                                'Order ID: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.order.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Order date
                          Row(
                            children: [
                              const Text(
                                'Order Date: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(DateTimeUtils.formatDateTime(
                                  widget.order.orderDate)),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Delivery method
                          Row(
                            children: [
                              const Text(
                                'Delivery Method: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(widget.order.deliveryMethod
                                  .toString()
                                  .split('.')
                                  .last),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Total amount
                          Row(
                            children: [
                              const Text(
                                'Total Amount: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                CurrencyUtils.formatCurrency(
                                    widget.order.totalAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),

                          // Show loyalty points earned
                          if (widget.order.loyaltyPointsEarned > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'Loyalty Points Earned: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${widget.order.loyaltyPointsEarned} points',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Show scheduled delivery time if applicable
                          if (widget.order.scheduledDate != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'Scheduled For: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateTimeUtils.formatDateTime(
                                      widget.order.scheduledDate!),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    CustomButton(
                      text: 'View Order Details',
                      onPressed: _navigateToOrderHistory,
                    ),
                    const SizedBox(height: 16),

                    CustomButton(
                      text: 'Continue Shopping',
                      onPressed: _navigateToHome,
                      isOutlined: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _navigateToOrderHistory() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
      (route) => false,
    );
  }
}
