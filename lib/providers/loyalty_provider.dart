import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/loyalty_model.dart';

class LoyaltyProvider with ChangeNotifier {
  final List<UserLoyalty> _usersLoyalty = [];
  UserLoyalty? _userLoyalty;
  List<LoyaltyReward> _availableRewards = [];
  bool _isLoading = false;
  String? _error;

  // Maps to store user points and rewards
  Map<String, int> _userPoints = {};
  Map<String, List<RedeemedReward>> _userRewards = {};

  List<LoyaltyReward> get availableRewards => _availableRewards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get user's loyalty points
  int getUserPoints(String userId) {
    return _userPoints[userId] ?? 0;
  }

  // Get user's redeemed rewards
  List<RedeemedReward> getUserRewards(String userId) {
    return _userRewards[userId] ?? [];
  }

  // Initialize loyalty system
  Future<void> initLoyalty() async {
    _setLoading(true);

    try {
      // In a real app, these would be fetched from a server
      // For demo, we'll create some sample rewards
      _availableRewards = [
        LoyaltyReward(
          id: 'reward-1',
          title: 'Free Shipping',
          description: 'Free shipping on your next order',
          pointsCost: 100,
          imageUrl: 'assets/images/free_shipping.png',
          expiryDate: DateTime.now().add(const Duration(days: 30)),
        ),
        LoyaltyReward(
          id: 'reward-2',
          title: '10% Discount',
          description: '10% off your next purchase',
          pointsCost: 200,
          imageUrl: 'assets/images/discount.png',
          expiryDate: DateTime.now().add(const Duration(days: 60)),
        ),
        LoyaltyReward(
          id: 'reward-3',
          title: 'Free Item',
          description: 'Get a free item with your next purchase',
          pointsCost: 500,
          imageUrl: 'assets/images/free_item.png',
          expiryDate: DateTime.now().add(const Duration(days: 90)),
        ),
      ];

      await _loadUserLoyaltyData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Load user loyalty data from storage
  Future<void> _loadUserLoyaltyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load user points
      final pointsJson = prefs.getString('user_loyalty_points');
      if (pointsJson != null) {
        final Map<String, dynamic> decoded = json.decode(pointsJson);
        _userPoints = decoded.map(
          (key, value) => MapEntry(key, value as int),
        );
      }

      // Load user rewards
      final rewardsJson = prefs.getString('user_loyalty_rewards');
      if (rewardsJson != null) {
        final Map<String, dynamic> decoded = json.decode(rewardsJson);

        _userRewards = decoded.map(
          (userId, rewards) {
            final List<RedeemedReward> userRewards = (rewards as List)
                .map((reward) => RedeemedReward.fromJson(reward))
                .toList();
            return MapEntry(userId, userRewards);
          },
        );
      }
    } catch (e) {
      debugPrint('Error loading loyalty data: $e');
    }
  }

  // Save user loyalty data to storage
  Future<void> _saveUserLoyaltyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save user points
      final pointsJson = json.encode(_userPoints);
      await prefs.setString('user_loyalty_points', pointsJson);

      // Save user rewards
      final Map<String, dynamic> rewardsMap = {};
      _userRewards.forEach((userId, rewards) {
        rewardsMap[userId] = rewards.map((reward) => reward.toJson()).toList();
      });

      final rewardsJson = json.encode(rewardsMap);
      await prefs.setString('user_loyalty_rewards', rewardsJson);
    } catch (e) {
      debugPrint('Error saving loyalty data: $e');
    }
  }

  // Add points to user's account
  Future<void> addPoints(String userId, int points) async {
    if (points <= 0) return;

    final currentPoints = _userPoints[userId] ?? 0;
    _userPoints[userId] = currentPoints + points;

    notifyListeners();
    await _saveUserLoyaltyData();
  }

  // Use points from user's account
  Future<bool> usePoints(String userId, int points) async {
    if (points <= 0) return false;

    final currentPoints = _userPoints[userId] ?? 0;

    if (currentPoints < points) {
      return false;
    }

    _userPoints[userId] = currentPoints - points;

    notifyListeners();
    await _saveUserLoyaltyData();
    return true;
  }

  // Redeem a reward
  Future<bool> redeemReward(String userId, String rewardId) async {
    // Find the reward
    final rewardIndex =
        _availableRewards.indexWhere((reward) => reward.id == rewardId);

    if (rewardIndex < 0) {
      return false;
    }

    final reward = _availableRewards[rewardIndex];
    final currentPoints = _userPoints[userId] ?? 0;

    // Check if user has enough points
    if (currentPoints < reward.pointsCost) {
      return false;
    }

    // Deduct points
    _userPoints[userId] = currentPoints - reward.pointsCost;

    // Add reward to user's account
    final userRewardsList = _userRewards[userId] ?? [];
    userRewardsList.add(
      RedeemedReward(
        rewardId: rewardId,
        redeemedDate: DateTime.now(),
        expiryDate: reward.expiryDate,
        code: 'CODE${DateTime.now().millisecondsSinceEpoch}',
      ),
    );

    _userRewards[userId] = userRewardsList;

    notifyListeners();
    await _saveUserLoyaltyData();
    return true;
  }

  // Mark a reward as used
  Future<void> markRewardAsUsed(String userId, String rewardId) async {
    if (!_userRewards.containsKey(userId)) {
      return;
    }

    final rewards = _userRewards[userId]!;
    final rewardIndex = rewards
        .indexWhere((reward) => reward.rewardId == rewardId && !reward.isUsed);

    if (rewardIndex >= 0) {
      // Create a new reward object with isUsed set to true
      final oldReward = rewards[rewardIndex];
      final updatedReward = RedeemedReward(
        rewardId: oldReward.rewardId,
        redeemedDate: oldReward.redeemedDate,
        expiryDate: oldReward.expiryDate,
        isUsed: true,
        code: oldReward.code,
      );

      rewards[rewardIndex] = updatedReward;

      notifyListeners();
      await _saveUserLoyaltyData();
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
