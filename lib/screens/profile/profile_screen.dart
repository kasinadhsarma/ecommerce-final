import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loyalty_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart';
import 'store_details_screen.dart';
import 'loyalty_rewards_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadUserData();
  }

  Future<void> _checkBiometricAvailability() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAvailable = await authProvider.isBiometricAvailable();

    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.user != null) {
      await orderProvider.loadOrders(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final loyaltyProvider = Provider.of<LoyaltyProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    // If not authenticated, show login prompt
    if (!authProvider.isAuthenticated) {
      return _buildLoginPrompt();
    }

    final user = authProvider.user!;
    final userPoints = loyaltyProvider.getUserPoints(user.id);
    final recentOrders = orderProvider.getRecentOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User profile card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // User avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.deepPurple.shade100,
                          child: Text(
                            user.name!.isNotEmpty
                                ? user.name!.substring(0, 1).toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // User name
                        Text(
                          user.name ?? 'Unknown User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // User email
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Edit profile button
                        CustomButton(
                          text: 'Edit Profile',
                          onPressed: () => _navigateToEditProfile(context),
                          isOutlined: true,
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Loyalty points section
                Card(
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
                          children: [
                            const Icon(
                              Icons.stars,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Loyalty Points',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              child: const Text('View Rewards'),
                              onPressed: () =>
                                  _navigateToLoyaltyRewards(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (userPoints % 100) / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.deepPurple.shade400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Points: $userPoints',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Next Reward: ${100 - (userPoints % 100)} more points',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Recent orders section
                if (recentOrders.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Orders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        child: const Text('View All'),
                        onPressed: () => _navigateToOrderHistory(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        recentOrders.length > 3 ? 3 : recentOrders.length,
                    itemBuilder: (context, index) {
                      final order = recentOrders[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            'Order #${order.id.substring(4, 12)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${DateTimeUtils.formatDate(order.orderDate)} - ${order.status.toString().split('.').last}',
                          ),
                          trailing: Text(
                            CurrencyUtils.formatCurrency(order.totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          onTap: () {
                            // Navigate to order details
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Settings section
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                _buildSettingItem(
                  'Payment Methods',
                  Icons.payment,
                  () {
                    // Navigate to payment methods
                  },
                ),

                _buildSettingItem(
                  'Notification Preferences',
                  Icons.notifications,
                  () {
                    // Navigate to notification settings
                  },
                ),

                if (_isBiometricAvailable)
                  _buildBiometricToggle(user.isBiometricEnabled),

                _buildSettingItem(
                  'Store Information',
                  Icons.store,
                  () => _navigateToStoreDetails(context),
                ),

                _buildSettingItem(
                  'Help & Support',
                  Icons.help,
                  () {
                    // Navigate to help & support
                  },
                ),

                _buildSettingItem(
                  'About App',
                  Icons.info,
                  () {
                    // Navigate to about app
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 100,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              const Text(
                'Sign In to Your Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Please sign in to access your profile, orders, and rewards.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Sign In',
                onPressed: () => _navigateToLogin(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.deepPurple,
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBiometricToggle(bool isEnabled) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          child: SwitchListTile(
            secondary: const Icon(
              Icons.fingerprint,
              color: Colors.deepPurple,
            ),
            title: const Text('Biometric Authentication'),
            value: isEnabled,
            onChanged: (value) async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);

              if (value) {
                await authProvider.enableBiometricLogin();
              } else {
                await authProvider.disableBiometricLogin();
              }

              setState(() {});
            },
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  void _navigateToOrderHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
    );
  }

  void _navigateToLoyaltyRewards(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoyaltyRewardsScreen()),
    );
  }

  void _navigateToStoreDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StoreDetailsScreen()),
    );
  }
}
