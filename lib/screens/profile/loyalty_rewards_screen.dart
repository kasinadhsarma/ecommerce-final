import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loyalty_provider.dart';
import '../../models/loyalty_model.dart' as lib_models;
import '../../widgets/common_widgets.dart';
import '../../utils/app_utils.dart';

class LoyaltyRewardsScreen extends StatefulWidget {
  const LoyaltyRewardsScreen({super.key});

  @override
  State<LoyaltyRewardsScreen> createState() => _LoyaltyRewardsScreenState();
}

class _LoyaltyRewardsScreenState extends State<LoyaltyRewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLoyaltyData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLoyaltyData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loyaltyProvider =
        Provider.of<LoyaltyProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.user != null) {
      await loyaltyProvider.loadUserLoyalty(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final loyaltyProvider = Provider.of<LoyaltyProvider>(context);

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loyalty Rewards'),
        ),
        body: const Center(
          child: Text('Please log in to access your loyalty rewards.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Rewards'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLoyaltyData,
        child: Column(
          children: [
            // Points summary
            _buildPointsSummary(loyaltyProvider),

            // Tab bar
            TabBar(
              controller: _tabController,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepPurple,
              tabs: const [
                Tab(
                  icon: Icon(Icons.card_giftcard),
                  text: 'Rewards',
                ),
                Tab(
                  icon: Icon(Icons.history),
                  text: 'History',
                ),
                Tab(
                  icon: Icon(Icons.info_outline),
                  text: 'About',
                ),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Rewards tab
                  _buildRewardsTab(loyaltyProvider),

                  // History tab
                  _buildHistoryTab(loyaltyProvider),

                  // About tab
                  _buildAboutTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsSummary(LoyaltyProvider loyaltyProvider) {
    final availablePoints = loyaltyProvider.userLoyalty?.points ?? 0;
    final membershipLevel =
        loyaltyProvider.userLoyalty?.membershipLevel ?? 'Bronze';
    final pointsToNextLevel =
        _getPointsToNextLevel(membershipLevel, availablePoints);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade700,
            Colors.deepPurple.shade900,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.stars,
                color: Colors.yellow,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                membershipLevel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Points',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    availablePoints.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Points Value',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyUtils.formatCurrency(availablePoints / 10),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (pointsToNextLevel > 0) ...[
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _getLevelProgress(membershipLevel, availablePoints),
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
            ),
            const SizedBox(height: 8),
            Text(
              '$pointsToNextLevel more points to reach ${_getNextLevel(membershipLevel)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardsTab(LoyaltyProvider loyaltyProvider) {
    final availablePoints = loyaltyProvider.userLoyalty?.points ?? 0;
    final rewards = _getAvailableRewards();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Available Rewards',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...rewards.map((reward) {
          final bool canRedeem = availablePoints >= reward.pointsCost;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and description
                  Row(
                    children: [
                      Icon(
                        reward.icon,
                        color: Colors.deepPurple,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reward.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              reward.description,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Points cost
                      Row(
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reward.pointsCost} points',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Redeem button
                      ElevatedButton(
                        onPressed: canRedeem
                            ? () => _redeemReward(context, reward)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canRedeem
                              ? Colors.deepPurple
                              : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          canRedeem ? 'Redeem' : 'Not Enough Points',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHistoryTab(LoyaltyProvider loyaltyProvider) {
    final history = loyaltyProvider.userLoyalty?.history ?? [];

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No loyalty activity yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your points history will appear here',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final activity = history[index];
        final isEarned = activity.points > 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isEarned
                        ? Colors.green.withAlpha(26) // 0.1 * 255 = ~26
                        : Colors.red.withAlpha(26), // 0.1 * 255 = ~26
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEarned ? Icons.add_circle : Icons.remove_circle,
                    color: isEarned ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateTimeUtils.formatDateTime(activity.date),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Points
                Text(
                  isEarned ? '+${activity.points}' : '${activity.points}',
                  style: TextStyle(
                    color: isEarned ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'About Our Loyalty Program',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Program explanation
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How It Works',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Our loyalty program rewards you for shopping with us. Earn points with every purchase and redeem them for discounts, free items, and exclusive perks.',
                ),
                const SizedBox(height: 16),

                // Earning points
                _buildInfoItem(
                  Icons.shopping_cart,
                  'Earning Points',
                  'Earn 1 point for every \$1 spent on purchases.',
                ),

                // Redeeming points
                _buildInfoItem(
                  Icons.redeem,
                  'Redeeming Points',
                  'Redeem your points for rewards. 10 points = \$1 in redemption value.',
                ),

                // Points expiration
                _buildInfoItem(
                  Icons.timer,
                  'Points Expiration',
                  'Points expire 12 months after they are earned if not redeemed.',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Membership levels
        const Text(
          'Membership Levels',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        _buildMembershipLevelCard(
          'Bronze',
          'Starting level',
          0,
          500,
          [
            'Earn 1 point per \$1 spent',
            'Birthday reward',
            'Special promotions',
          ],
          Colors.brown.shade300,
        ),

        _buildMembershipLevelCard(
          'Silver',
          'Earn 500+ points in a year',
          500,
          1000,
          [
            'All Bronze benefits',
            'Earn 1.25 points per \$1 spent',
            'Free shipping on orders \$50+',
            'Early access to sales',
          ],
          Colors.grey.shade400,
        ),

        _buildMembershipLevelCard(
          'Gold',
          'Earn 1000+ points in a year',
          1000,
          2500,
          [
            'All Silver benefits',
            'Earn 1.5 points per \$1 spent',
            'Free shipping on all orders',
            'Exclusive Gold member events',
            'Priority customer service',
          ],
          Colors.amber,
        ),

        _buildMembershipLevelCard(
          'Platinum',
          'Earn 2500+ points in a year',
          2500,
          double.infinity,
          [
            'All Gold benefits',
            'Earn 2 points per \$1 spent',
            'Dedicated account manager',
            'Annual surprise gift',
            'Free returns',
            'VIP access to new products',
          ],
          Colors.grey.shade700,
        ),

        const SizedBox(height: 24),

        // Terms and conditions
        const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The loyalty program is subject to the following terms:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text('• Points cannot be transferred or sold'),
                Text(
                    '• We reserve the right to modify the program at any time'),
                Text('• Points have no cash value'),
                Text('• Membership status is evaluated annually'),
                Text(
                    '• Fraudulent activity will result in account termination'),
                SizedBox(height: 8),
                Text(
                  'For the complete terms and conditions, please contact customer support.',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.deepPurple,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipLevelCard(
    String level,
    String description,
    int minPoints,
    double maxPoints,
    List<String> benefits,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Level header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Text(
              level,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Level details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  maxPoints.isFinite
                      ? 'Required points: $minPoints-${maxPoints.toInt()}'
                      : 'Required points: $minPoints+',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Benefits:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...benefits.map((benefit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(benefit)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<LoyaltyReward> _getAvailableRewards() {
    return [
      LoyaltyReward(
        id: '1',
        title: '\$5 Off Your Next Order',
        description: 'Get \$5 off on your next purchase',
        pointsCost: 50,
        icon: Icons.discount,
      ),
      LoyaltyReward(
        id: '2',
        title: '\$10 Off Your Next Order',
        description: 'Get \$10 off on your next purchase',
        pointsCost: 100,
        icon: Icons.discount,
      ),
      LoyaltyReward(
        id: '3',
        title: 'Free Standard Shipping',
        description: 'Free shipping on your next order',
        pointsCost: 75,
        icon: Icons.local_shipping,
      ),
      LoyaltyReward(
        id: '4',
        title: '15% Off Entire Purchase',
        description: 'Get 15% off your entire next order',
        pointsCost: 150,
        icon: Icons.percent,
      ),
      LoyaltyReward(
        id: '5',
        title: 'Free Premium Item',
        description: 'Get a free premium item with your next purchase',
        pointsCost: 200,
        icon: Icons.card_giftcard,
      ),
      LoyaltyReward(
        id: '6',
        title: '\$25 Off Your Next Order',
        description: 'Get \$25 off on your next purchase',
        pointsCost: 250,
        icon: Icons.discount,
      ),
    ];
  }

  void _redeemReward(BuildContext context, LoyaltyReward reward) {
    final loyaltyProvider =
        Provider.of<LoyaltyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Reward'),
        content: Text(
            'Are you sure you want to redeem ${reward.title} for ${reward.pointsCost} points?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              if (authProvider.isAuthenticated && authProvider.user != null) {
                // Create a LoyaltyReward model from our UI reward
                final modelReward = lib_models.LoyaltyReward(
                  id: reward.id,
                  title: reward.title,
                  description: reward.description,
                  pointsCost: reward.pointsCost,
                );

                final success = await loyaltyProvider.redeemPoints(
                  authProvider.user!.id,
                  modelReward,
                );

                if (success) {
                  if (!mounted) return;

                  // Store context in local variable
                  final currentContext = context;

                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    SnackBar(
                      content: Text('Successfully redeemed ${reward.title}!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Show reward code
                  _showRewardCode(currentContext, reward);
                } else {
                  if (!mounted) return;

                  // Store context in local variable
                  final currentContext = context;

                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Failed to redeem reward. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  void _showRewardCode(BuildContext context, LoyaltyReward reward) {
    // Generate a fake reward code
    final rewardCode =
        'REWARD-${reward.id}-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 11)}';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(reward.icon, color: Colors.deepPurple, size: 30),
                const SizedBox(width: 12),
                Text(
                  reward.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Reward Code:',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.deepPurple.shade200,
                ),
              ),
              child: Text(
                rewardCode,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Use this code at checkout to apply your reward',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Copy Code',
              icon: Icons.copy,
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reward code copied to clipboard'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getNextLevel(String currentLevel) {
    switch (currentLevel) {
      case 'Bronze':
        return 'Silver';
      case 'Silver':
        return 'Gold';
      case 'Gold':
        return 'Platinum';
      default:
        return '';
    }
  }

  int _getPointsToNextLevel(String currentLevel, int currentPoints) {
    switch (currentLevel) {
      case 'Bronze':
        return 500 - currentPoints;
      case 'Silver':
        return 1000 - currentPoints;
      case 'Gold':
        return 2500 - currentPoints;
      default:
        return 0;
    }
  }

  double _getLevelProgress(String currentLevel, int currentPoints) {
    switch (currentLevel) {
      case 'Bronze':
        return currentPoints / 500;
      case 'Silver':
        return (currentPoints - 500) / 500;
      case 'Gold':
        return (currentPoints - 1000) / 1500;
      default:
        return 1.0;
    }
  }
}

class LoyaltyReward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final IconData icon;

  LoyaltyReward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.icon,
  });
}
