import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// MyID Foydalanuvchi Ma'lumotlarini Olish Servisi
class MyIdUserService {
  static const String _backendUrl =
      'https://greenmarket-backend-lilac.vercel.app';

  /// Code orqali foydalanuvchi ma'lumotlarini olish
  static Future<Map<String, dynamic>> getUserDataByCode(String code) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 MyID User Service: Code orqali ma\'lumot olinmoqda...');
        debugPrint('   - code: $code');
      }

      final response = await http
          .get(
            Uri.parse('$_backendUrl/api/myid/data/code=$code'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Backend bilan aloqa vaqti tugadi');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('✅ Foydalanuvchi ma\'lumotlari olindi');
          debugPrint('   - Status: ${response.statusCode}');
        }

        return {'success': true, 'data': data['data'] ?? data};
      } else {
        if (kDebugMode) {
          debugPrint('❌ Xato: ${response.statusCode}');
          debugPrint('   - Body: ${response.body}');
        }

        throw Exception('Backend xatosi: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ MyID User Service xatosi: $e');
      }

      return {'success': false, 'error': e.toString()};
    }
  }

  /// Barcha foydalanuvchilar (Admin)
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📤 MyID User Service: Barcha foydalanuvchilar olinmoqda...',
        );
      }

      final response = await http
          .get(
            Uri.parse('$_backendUrl/api/myid/users'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Backend bilan aloqa vaqti tugadi');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('✅ Foydalanuvchilar olindi');
          debugPrint('   - Jami: ${data['data']['total']}');
        }

        return {'success': true, 'data': data['data']};
      } else {
        throw Exception('Backend xatosi: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Foydalanuvchilar olishda xato: $e');
      }

      return {'success': false, 'error': e.toString()};
    }
  }

  /// Statistika (Admin)
  static Future<Map<String, dynamic>> getStats() async {
    try {
      if (kDebugMode) {
        debugPrint('📤 MyID User Service: Statistika olinmoqda...');
      }

      final response = await http
          .get(
            Uri.parse('$_backendUrl/api/myid/stats'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Backend bilan aloqa vaqti tugadi');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (kDebugMode) {
          debugPrint('✅ Statistika olindi');
          debugPrint(
            '   - Jami foydalanuvchilar: ${data['data']['total_users']}',
          );
          debugPrint('   - Bugun: ${data['data']['today_registrations']}');
        }

        return {'success': true, 'data': data['data']};
      } else {
        throw Exception('Backend xatosi: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Statistika olishda xato: $e');
      }

      return {'success': false, 'error': e.toString()};
    }
  }

  /// Health check
  static Future<bool> checkHealth() async {
    try {
      if (kDebugMode) {
        debugPrint('📤 MyID User Service: Health check...');
      }

      final response = await http
          .get(Uri.parse('$_backendUrl/api/health'))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Backend bilan aloqa vaqti tugadi');
            },
          );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ Backend sog\'lom');
        }
        return true;
      } else {
        if (kDebugMode) {
          debugPrint('❌ Backend xatosi: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Health check xatosi: $e');
      }
      return false;
    }
  }
}
