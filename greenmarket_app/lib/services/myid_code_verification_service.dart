import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// MyID Code Verification Service - SDK'dan kelgan kodni tekshirish
class MyIdCodeVerificationService {
  static const String _backendUrl = 'https://myid-backend.vercel.app';

  /// SDK'dan kelgan kodni backend'ga yuborish va foydalanuvchi ma'lumotlarini olish
  static Future<Map<String, dynamic>> verifyCode({
    required String code,
    required String sessionId,
  }) async {
    try {
      debugPrint('🔵 VERIFY CODE: Kodni tekshirish sorov...');
      debugPrint('   Code: ${code.substring(0, 20)}...');
      debugPrint('   Session ID: $sessionId');

      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/myid/verify-code'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'code': code, 'session_id': sessionId}),
          )
          .timeout(const Duration(seconds: 60));

      debugPrint('🔵 VERIFY CODE: Response status: ${response.statusCode}');
      debugPrint(
        '🔵 VERIFY CODE: Response body: ${response.body.substring(0, 200)}...',
      );

      if (response.statusCode == 200) {
        final respData = json.decode(response.body);

        if (respData['success'] == true) {
          final profile = respData['profile'] ?? {};
          debugPrint('✅ VERIFY CODE: Foydalanuvchi ma\'lumotlari olindi');
          debugPrint(
            '   Name: ${profile['first_name']} ${profile['last_name']}',
          );
          debugPrint('   PINFL: ${profile['pinfl']}');

          return {
            'success': true,
            'session_id': sessionId,
            'profile': profile,
            'reuid': respData['reuid'],
            'comparison_value': respData['comparison_value'],
            'image': respData['image'],
            'base64_image': respData['base64_image'],
          };
        }

        debugPrint('❌ VERIFY CODE: Backend xatosi - ${respData['error']}');
        return {
          'success': false,
          'error': respData['error'] ?? 'Kodni tekshirishda xato',
        };
      } else {
        debugPrint('❌ VERIFY CODE: HTTP ${response.statusCode}');
        return {
          'success': false,
          'error': 'Backend error: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('❌ VERIFY CODE XATOSI: $e');
      if (e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'error': 'Kodni tekshirishda timeout (60s). Iltimos qayta urining.',
        };
      }
      return {'success': false, 'error': 'Kodni tekshirish xatosi: $e'};
    }
  }
}
