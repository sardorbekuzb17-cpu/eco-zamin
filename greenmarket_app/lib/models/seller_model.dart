class SellerModel {
  final String id;
  final String name;
  final String description;
  final String phone;
  final String email;
  final String region;
  final String district;
  final String address;
  final String profileImage;
  final List<String> gallery;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isActive;
  final DateTime joinDate;
  final List<String> categories;
  final Map<String, dynamic> businessInfo;
  final DeliveryInfo deliveryInfo;

  SellerModel({
    required this.id,
    required this.name,
    required this.description,
    required this.phone,
    required this.email,
    required this.region,
    required this.district,
    required this.address,
    required this.profileImage,
    required this.gallery,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.isActive,
    required this.joinDate,
    required this.categories,
    required this.businessInfo,
    required this.deliveryInfo,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      region: json['region'] ?? '',
      district: json['district'] ?? '',
      address: json['address'] ?? '',
      profileImage: json['profileImage'] ?? '',
      gallery: List<String>.from(json['gallery'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      joinDate: DateTime.parse(
        json['joinDate'] ?? DateTime.now().toIso8601String(),
      ),
      categories: List<String>.from(json['categories'] ?? []),
      businessInfo: Map<String, dynamic>.from(json['businessInfo'] ?? {}),
      deliveryInfo: DeliveryInfo.fromJson(json['deliveryInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'phone': phone,
      'email': email,
      'region': region,
      'district': district,
      'address': address,
      'profileImage': profileImage,
      'gallery': gallery,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'isActive': isActive,
      'joinDate': joinDate.toIso8601String(),
      'categories': categories,
      'businessInfo': businessInfo,
      'deliveryInfo': deliveryInfo.toJson(),
    };
  }

  String get fullAddress => '$region, $district, $address';

  String get ratingText => rating.toStringAsFixed(1);

  bool get hasDelivery => deliveryInfo.isAvailable;
}

class DeliveryInfo {
  final bool isAvailable;
  final double freeDeliveryMinAmount;
  final double deliveryFee;
  final List<String> deliveryAreas;
  final String estimatedTime;
  final Map<String, String> workingHours;

  DeliveryInfo({
    required this.isAvailable,
    required this.freeDeliveryMinAmount,
    required this.deliveryFee,
    required this.deliveryAreas,
    required this.estimatedTime,
    required this.workingHours,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      isAvailable: json['isAvailable'] ?? false,
      freeDeliveryMinAmount: (json['freeDeliveryMinAmount'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      deliveryAreas: List<String>.from(json['deliveryAreas'] ?? []),
      estimatedTime: json['estimatedTime'] ?? '',
      workingHours: Map<String, String>.from(json['workingHours'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'freeDeliveryMinAmount': freeDeliveryMinAmount,
      'deliveryFee': deliveryFee,
      'deliveryAreas': deliveryAreas,
      'estimatedTime': estimatedTime,
      'workingHours': workingHours,
    };
  }

  String get formattedDeliveryFee {
    return deliveryFee
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  String get formattedFreeDeliveryMin {
    return freeDeliveryMinAmount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}
