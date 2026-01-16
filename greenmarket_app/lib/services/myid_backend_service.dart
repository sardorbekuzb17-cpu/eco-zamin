import 'dart:convert';
import 'package:http/http.dart' as http;

class MyIdBackendService {
  static const String backendUrl = 'https://greenmarket-api.vercel.app';

  // BO'SH Session yaratish - pasport ma'lumotlari MyID SDK'da kiritiladi
  static Future<Map<String, dynamic>> createEmptySession() async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/myid/create-session'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}), // Bo'sh obyekt
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': 'Server xatosi: ${response.statusCode}',
          'error_details': errorData['error_details'],
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Xatolik: ${e.toString()}'};
    }
  }

  // Pasport ma'lumotlarini MyID orqali tekshirish
  static Future<Map<String, dynamic>> verifyPassport({
    required String passportSeries,
    required String passportNumber,
    required String birthDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/myid/verify-passport'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'passport_series': passportSeries,
          'passport_number': passportNumber,
          'birth_date': birthDate,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Server xatosi: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Xatolik: ${e.toString()}'};
    }
  }

  // Backend health check
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
