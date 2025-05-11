import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/loyalty_model.dart';

class LoyaltyProvider with ChangeNotifier {
  UserLoyalty? _userLoyalty;
  List<LoyaltyReward> _availableRewards = [];
  bool _isLoading = false;
  String? _error;

  // Maps to store user points and rewards
  final Map<String, int> _userPoints = {};
  final Map<String, List<RedeemedReward>> _userRewards = {};

  List<LoyaltyReward> get availableRewards => _availableRewards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserLoyalty? get userLoyalty => _userLoyalty;

  // Get user's loyalty points
  int getUserPoints(String userId) {
    return _userPoints[userId] ?? 0;
  }

  // Get user's redeemed rewards
  List<RedeemedReward> getUserRewards(String userId) {
    return _userRewards[userId] ?? [];
  }

  // Set loading state
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
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

      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
    notifyListeners();
  }

  // Load user loyalty data
  Future<void> loadUserLoyalty(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final loyaltyDataString = prefs.getString('loyalty_$userId');

      if (loyaltyDataString != null) {
        // Load saved loyalty data
        final Map<String, dynamic> loyaltyData = json.decode(loyaltyDataString);
        _userLoyalty = UserLoyalty.fromJson(loyaltyData);
      } else {
        // Create new loyalty profile if none exists
        _userLoyalty = UserLoyalty(
          userId: userId,
          points: 100, // Start with 100 points for demo
          membershipLevel: 'Bronze',
          history: [
            LoyaltyActivity(
              date: DateTime.now(),
              description: 'Welcome bonus',
              points: 100,
              type: 'earned',
            )
          ],
        );

        // Save the new loyalty profile
        await _saveUserLoyalty(userId);
      }

      _userPoints[userId] = _userLoyalty?.points ?? 0;

      // Load redeemed rewards
      final redeemedRewardsString = prefs.getString('redeemed_rewards_$userId');
      if (redeemedRewardsString != null) {
        final List<dynamic> rewardsData = json.decode(redeemedRewardsString);
        _userRewards[userId] = rewardsData
            .map((reward) => RedeemedReward.fromJson(reward))
            .toList();
      } else {
        _userRewards[userId] = [];
      }
    } catch (e) {
      _error = 'Failed to load loyalty data: $e';
      if (kDebugMode) {
        debugPrint(_error);
      }
    }

    _setLoading(false);
    notifyListeners();
  }

  // Save user loyalty data to local storage
  Future<void> _saveUserLoyalty(String userId) async {
    if (_userLoyalty == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'loyalty_$userId', json.encode(_userLoyalty!.toJson()));
  }

  // Save redeemed rewards to local storage
  Future<void> _saveRedeemedRewards(String userId) async {
    final rewards = _userRewards[userId] ?? [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'redeemed_rewards_$userId',
      json.encode(rewards.map((reward) => reward.toJson()).toList()),
    );
  }

  // Redeem points for a reward
  Future<bool> redeemPoints(String userId, LoyaltyReward reward) async {
    _setLoading(true);
    _error = null;

    try {
      // Check if user has enough points
      final currentPoints = _userPoints[userId] ?? 0;
      if (currentPoints < reward.pointsCost) {
        _error = 'Not enough points to redeem this reward';
        _setLoading(false);
        notifyListeners();
        return false;
      }

      // Deduct points
      _userPoints[userId] = currentPoints - reward.pointsCost;

      // Update user loyalty
      if (_userLoyalty != null && _userLoyalty!.userId == userId) {
        _userLoyalty = _userLoyalty!.copyWith(
          points: _userPoints[userId],
          history: [
            ..._userLoyalty!.history,
            LoyaltyActivity(
              date: DateTime.now(),
              description: 'Redeemed: ${reward.title}',
              points: -reward.pointsCost,
              type: 'redeemed',
            )
          ],
        );
      }

      // Add to redeemed rewards
      final redeemedReward = RedeemedReward(
        rewardId: reward.id,
        redeemedDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        code: 'CODE${DateTime.now().millisecondsSinceEpoch}',
      );

      _userRewards[userId] = [...(_userRewards[userId] ?? []), redeemedReward];

      // Save updated data
      await _saveUserLoyalty(userId);
      await _saveRedeemedRewards(userId);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to redeem reward: $e';
      if (kDebugMode) {
        debugPrint(_error);
      }
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Mark a reward as used
  Future<bool> useReward(String userId, String rewardId) async {
    _setLoading(true);

    try {
      final rewards = _userRewards[userId] ?? [];
      final index =
          rewards.indexWhere((r) => r.rewardId == rewardId && !r.isUsed);

      if (index < 0) {
        _setLoading(false);
        return false;
      }

      final oldReward = rewards[index];
      final updatedReward = RedeemedReward(
        rewardId: oldReward.rewardId,
        redeemedDate: oldReward.redeemedDate,
        expiryDate: oldReward.expiryDate,
        isUsed: true,
        code: oldReward.code,
      );

      rewards[index] = updatedReward;
      _userRewards[userId] = rewards;

      await _saveRedeemedRewards(userId);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to use reward: $e';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
}
