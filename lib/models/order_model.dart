import 'cart_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled
}

enum DeliveryMethod { pickup, delivery }

class OrderAddress {
  final String address;
  final String city;
  final String zipCode;
  final String? additionalInfo;

  OrderAddress({
    required this.address,
    required this.city,
    required this.zipCode,
    this.additionalInfo,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      address: json['address'],
      city: json['city'],
      zipCode: json['zipCode'],
      additionalInfo: json['additionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'zipCode': zipCode,
      'additionalInfo': additionalInfo,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final DateTime? scheduledDate;
  final OrderStatus status;
  final DeliveryMethod deliveryMethod;
  final OrderAddress? deliveryAddress;
  final String? paymentMethod;
  final String? paymentId;
  final int loyaltyPointsEarned;
  final int loyaltyPointsUsed;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.scheduledDate,
    this.status = OrderStatus.pending,
    required this.deliveryMethod,
    this.deliveryAddress,
    this.paymentMethod,
    this.paymentId,
    this.loyaltyPointsEarned = 0,
    this.loyaltyPointsUsed = 0,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'],
      orderDate: DateTime.parse(json['orderDate']),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      status: OrderStatus.values[json['status']],
      deliveryMethod: DeliveryMethod.values[json['deliveryMethod']],
      deliveryAddress: json['deliveryAddress'] != null
          ? OrderAddress.fromJson(json['deliveryAddress'])
          : null,
      paymentMethod: json['paymentMethod'],
      paymentId: json['paymentId'],
      loyaltyPointsEarned: json['loyaltyPointsEarned'] ?? 0,
      loyaltyPointsUsed: json['loyaltyPointsUsed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'status': status.index,
      'deliveryMethod': deliveryMethod.index,
      'deliveryAddress': deliveryAddress?.toJson(),
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'loyaltyPointsUsed': loyaltyPointsUsed,
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? totalAmount,
    DateTime? orderDate,
    DateTime? scheduledDate,
    OrderStatus? status,
    DeliveryMethod? deliveryMethod,
    OrderAddress? deliveryAddress,
    String? paymentMethod,
    String? paymentId,
    int? loyaltyPointsEarned,
    int? loyaltyPointsUsed,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
    );
  }
}
