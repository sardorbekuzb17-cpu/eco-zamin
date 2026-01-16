class OrderModel {
  final String id;
  final String userId;
  final String userPhone;
  final String userName;
  final List<OrderItem> items;
  final double totalAmount;
  final String currency;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String paymentMethod;
  final DeliveryAddress deliveryAddress;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? notes;
  final String? trackingNumber;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userPhone,
    required this.userName,
    required this.items,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.orderDate,
    this.deliveryDate,
    this.notes,
    this.trackingNumber,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userPhone: json['userPhone'] ?? '',
      userName: json['userName'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'UZS',
      status: OrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (s) => s.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: json['paymentMethod'] ?? '',
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress'] ?? {}),
      orderDate: DateTime.parse(
        json['orderDate'] ?? DateTime.now().toIso8601String(),
      ),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      notes: json['notes'],
      trackingNumber: json['trackingNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userPhone': userPhone,
      'userName': userName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress.toJson(),
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'notes': notes,
      'trackingNumber': trackingNumber,
    };
  }

  String get formattedTotal {
    return totalAmount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  String getStatusText(String langCode) {
    switch (status) {
      case OrderStatus.pending:
        return langCode == 'uz'
            ? 'Kutilmoqda'
            : langCode == 'ru'
            ? 'Ожидание'
            : 'Pending';
      case OrderStatus.confirmed:
        return langCode == 'uz'
            ? 'Tasdiqlandi'
            : langCode == 'ru'
            ? 'Подтверждено'
            : 'Confirmed';
      case OrderStatus.preparing:
        return langCode == 'uz'
            ? 'Tayyorlanmoqda'
            : langCode == 'ru'
            ? 'Готовится'
            : 'Preparing';
      case OrderStatus.shipping:
        return langCode == 'uz'
            ? 'Yetkazilmoqda'
            : langCode == 'ru'
            ? 'Доставляется'
            : 'Shipping';
      case OrderStatus.delivered:
        return langCode == 'uz'
            ? 'Yetkazildi'
            : langCode == 'ru'
            ? 'Доставлено'
            : 'Delivered';
      case OrderStatus.cancelled:
        return langCode == 'uz'
            ? 'Bekor qilindi'
            : langCode == 'ru'
            ? 'Отменено'
            : 'Cancelled';
    }
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String unit;
  final String sellerId;
  final String sellerName;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.sellerId,
    required this.sellerName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      unit: json['unit'] ?? 'dona',
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'sellerId': sellerId,
      'sellerName': sellerName,
    };
  }

  double get totalPrice => price * quantity;
}

class DeliveryAddress {
  final String fullName;
  final String phone;
  final String region;
  final String district;
  final String address;
  final String? landmark;
  final double? latitude;
  final double? longitude;

  DeliveryAddress({
    required this.fullName,
    required this.phone,
    required this.region,
    required this.district,
    required this.address,
    this.landmark,
    this.latitude,
    this.longitude,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      region: json['region'] ?? '',
      district: json['district'] ?? '',
      address: json['address'] ?? '',
      landmark: json['landmark'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'region': region,
      'district': district,
      'address': address,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullAddress {
    return '$region, $district, $address${landmark != null ? ', $landmark' : ''}';
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  shipping,
  delivered,
  cancelled,
}

enum PaymentStatus { pending, paid, failed, refunded }
