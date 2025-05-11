class User {
  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? photoUrl;
  final String? gender;
  final DateTime? birthDate;
  final String? profileImageUrl;
  final int loyaltyPoints;
  final List<String> favoriteProductIds;
  final bool isBiometricEnabled;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.photoUrl,
    this.gender,
    this.birthDate,
    this.profileImageUrl,
    this.loyaltyPoints = 0,
    this.favoriteProductIds = const [],
    this.isBiometricEnabled = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      gender: json['gender'],
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      profileImageUrl: json['profileImageUrl'],
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      favoriteProductIds: List<String>.from(json['favoriteProductIds'] ?? []),
      isBiometricEnabled: json['isBiometricEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'gender': gender,
      'birthDate': birthDate?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'loyaltyPoints': loyaltyPoints,
      'favoriteProductIds': favoriteProductIds,
      'isBiometricEnabled': isBiometricEnabled,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? photoUrl,
    String? gender,
    DateTime? birthDate,
    String? profileImageUrl,
    int? loyaltyPoints,
    List<String>? favoriteProductIds,
    bool? isBiometricEnabled,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }
}
