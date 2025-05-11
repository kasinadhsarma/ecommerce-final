// Class to represent a user's loyalty status and history
class UserLoyalty {
  final String userId;
  final int points;
  final String membershipLevel;
  final List<LoyaltyActivity> history;

  UserLoyalty({
    required this.userId,
    required this.points,
    required this.membershipLevel,
    required this.history,
  });

  factory UserLoyalty.fromJson(Map<String, dynamic> json) {
    return UserLoyalty(
      userId: json['userId'],
      points: json['points'],
      membershipLevel: json['membershipLevel'],
      history: (json['history'] as List)
          .map((activity) => LoyaltyActivity.fromJson(activity))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'points': points,
      'membershipLevel': membershipLevel,
      'history': history.map((activity) => activity.toJson()).toList(),
    };
  }

  UserLoyalty copyWith({
    String? userId,
    int? points,
    String? membershipLevel,
    List<LoyaltyActivity>? history,
  }) {
    return UserLoyalty(
      userId: userId ?? this.userId,
      points: points ?? this.points,
      membershipLevel: membershipLevel ?? this.membershipLevel,
      history: history ?? this.history,
    );
  }
}

// Class to represent a loyalty activity (earning or redeeming points)
class LoyaltyActivity {
  final DateTime date;
  final int points;
  final String description;
  final String type; // 'earn' or 'redeem'

  LoyaltyActivity({
    required this.date,
    required this.points,
    required this.description,
    required this.type,
  });

  factory LoyaltyActivity.fromJson(Map<String, dynamic> json) {
    return LoyaltyActivity(
      date: DateTime.parse(json['date']),
      points: json['points'],
      description: json['description'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'points': points,
      'description': description,
      'type': type,
    };
  }
}

// Class to represent a loyalty reward that can be redeemed
class LoyaltyReward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String? imageUrl;
  final DateTime? expiryDate;

  LoyaltyReward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    this.imageUrl,
    this.expiryDate,
  });

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    return LoyaltyReward(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pointsCost: json['pointsCost'],
      imageUrl: json['imageUrl'],
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsCost': pointsCost,
      'imageUrl': imageUrl,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }
}

// Class to represent a redeemed reward
class RedeemedReward {
  final String rewardId;
  final DateTime redeemedDate;
  final DateTime? expiryDate;
  final bool isUsed;
  final String code;

  RedeemedReward({
    required this.rewardId,
    required this.redeemedDate,
    this.expiryDate,
    this.isUsed = false,
    required this.code,
  });

  factory RedeemedReward.fromJson(Map<String, dynamic> json) {
    return RedeemedReward(
      rewardId: json['rewardId'],
      redeemedDate: DateTime.parse(json['redeemedDate']),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      isUsed: json['isUsed'] ?? false,
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rewardId': rewardId,
      'redeemedDate': redeemedDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'isUsed': isUsed,
      'code': code,
    };
  }
}
