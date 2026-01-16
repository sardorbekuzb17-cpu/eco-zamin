class ProductModel {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final double price;
  final String currency;
  final String category;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final String region;
  final String district;
  final bool isAvailable;
  final int stockQuantity;
  final Map<String, String> unit;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final Map<String, dynamic> specifications;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.category,
    required this.images,
    required this.sellerId,
    required this.sellerName,
    required this.region,
    required this.district,
    required this.isAvailable,
    required this.stockQuantity,
    required this.unit,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.specifications,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: Map<String, String>.from(json['name'] ?? {}),
      description: Map<String, String>.from(json['description'] ?? {}),
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'UZS',
      category: json['category'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      region: json['region'] ?? '',
      district: json['district'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      stockQuantity: json['stockQuantity'] ?? 0,
      unit: Map<String, String>.from(json['unit'] ?? {}),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      tags: List<String>.from(json['tags'] ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'category': category,
      'images': images,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'region': region,
      'district': district,
      'isAvailable': isAvailable,
      'stockQuantity': stockQuantity,
      'unit': unit,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'specifications': specifications,
    };
  }

  String getName(String langCode) {
    return name[langCode] ?? name['uz'] ?? 'Noma\'lum mahsulot';
  }

  String getDescription(String langCode) {
    return description[langCode] ?? description['uz'] ?? '';
  }

  String getUnit(String langCode) {
    return unit[langCode] ?? unit['uz'] ?? 'dona';
  }

  String get formattedPrice {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  bool get isInStock => isAvailable && stockQuantity > 0;
}
