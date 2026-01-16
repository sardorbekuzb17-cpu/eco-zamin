import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/seller_model.dart';

class ApiService {
  static const String baseUrl = 'https://greenmarket-api.vercel.app/api';

  // Mahsulotlar
  static Future<List<ProductModel>> getProducts({
    String? category,
    String? region,
    String? search,
  }) async {
    try {
      String url = '$baseUrl/products';
      Map<String, String> queryParams = {};

      if (category != null) queryParams['category'] = category;
      if (region != null) queryParams['region'] = region;
      if (search != null) queryParams['search'] = search;

      if (queryParams.isNotEmpty) {
        url =
            '$url?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['products'] as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Mahsulotlarni yuklashda xatolik');
      }
    } catch (e) {
      throw Exception('Internet aloqasi xatosi: $e');
    }
  }

  // Buyurtma berish
  static Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return OrderModel.fromJson(data['order']);
      } else {
        throw Exception('Buyurtma berishda xatolik');
      }
    } catch (e) {
      throw Exception('Buyurtma xatosi: $e');
    }
  }

  // Buyurtmalar tarixi
  static Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/user/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['orders'] as List)
            .map((json) => OrderModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Buyurtmalar tarixini yuklashda xatolik');
      }
    } catch (e) {
      throw Exception('Buyurtmalar xatosi: $e');
    }
  }

  // Sotuvchilar
  static Future<List<SellerModel>> getSellers({String? region}) async {
    try {
      String url = '$baseUrl/sellers';
      if (region != null) {
        url += '?region=$region';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['sellers'] as List)
            .map((json) => SellerModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Sotuvchilarni yuklashda xatolik');
      }
    } catch (e) {
      throw Exception('Sotuvchilar xatosi: $e');
    }
  }

  // To'lov
  static Future<Map<String, dynamic>> processPayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'paymentDetails': paymentDetails,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('To\'lov amalga oshmadi');
      }
    } catch (e) {
      throw Exception('To\'lov xatosi: $e');
    }
  }
}
