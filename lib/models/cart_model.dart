import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  final Map<String, dynamic>? customizations;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.customizations,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    Map<String, dynamic>? customizations,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customizations: customizations ?? this.customizations,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      customizations: json['customizations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'customizations': customizations,
    };
  }
}

class Cart {
  final List<CartItem> items;
  final double deliveryFee;
  final double? discount;
  final String? promoCode;

  Cart({
    this.items = const [],
    this.deliveryFee = 0.0,
    this.discount,
    this.promoCode,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  double get total {
    double totalWithFee = subtotal + deliveryFee;
    if (discount != null) {
      return totalWithFee - discount!;
    }
    return totalWithFee;
  }

  Cart copyWith({
    List<CartItem>? items,
    double? deliveryFee,
    double? discount,
    String? promoCode,
  }) {
    return Cart(
      items: items ?? this.items,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      promoCode: promoCode ?? this.promoCode,
    );
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List)
          .map((itemJson) => CartItem.fromJson(itemJson))
          .toList(),
      deliveryFee: json['deliveryFee'],
      discount: json['discount'],
      promoCode: json['promoCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryFee': deliveryFee,
      'discount': discount,
      'promoCode': promoCode,
    };
  }
}
