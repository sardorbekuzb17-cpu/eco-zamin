import 'dart:convert';
import 'package:http/http.dart' as http;

class MyIdBackendService {
  static const String backendUrl =
      'https://greenmarket-backend-lilac.vercel.app';

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

  // OAuth Access Token olish
  // API: POST https://myid.uz/api/v1/auth/clients/access-token
  // Javob parametrlari (rasmdan):
  // 1. access_token - Kirish tokeni (JWT) - tor - 512+ belgi
  // 2. expires_in - Tokenning ishlash muddati (soniya) - raqam
  // 3. token_type - Token turi (Tashqidigan) - tor - 50 belgi
  static Future<Map<String, dynamic>> getAccessToken({
    required String clientId,
    required String clientSecret,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://myid.uz/api/v1/auth/clients/access-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'client_id': clientId,
          'client_secret': clientSecret,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Misol javob:
        // {
        //   "access_token": "eyJhb5ci...",
        //   "expires_in": 604800,
        //   "token_type": "Bearer"
        // }
        return {
          'success': true,
          'access_token': data['access_token'], // JWT token (512+ belgi)
          'expires_in': data['expires_in'], // Soniya (604800 = 7 kun)
          'token_type': data['token_type'], // "Bearer"
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': 'Access token olishda xatolik: ${response.statusCode}',
          'error_details': errorData,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Tarmoq xatosi: ${e.toString()}'};
    }
  }

  // Sessiya yaratish (PINFL yoki Pasport ma'lumotlari bilan)
  // API: POST {myid_host}/api/v2/sdk/sessions
  // Avtorizatsiya: Bearer {access_token}
  // So'rov parametrlari:
  // - phone_number: satr (min_len=12, max_len=13) | null - Telefon raqami
  // - birth_date: satr (YYYY-MM-DD) | null - Tug'ilgan sana
  // - is_resident: bool | null - Rezidentmi (standart: rost)
  // - pinfl: satr (14) | null - PINFL
  // - pass_data: satr | null - Pasport seriyasi va raqami
  // - threshold: suzuvchi | null - 0.5 dan 0.99 gacha
  static Future<Map<String, dynamic>> createSession({
    required String accessToken,
    String? phoneNumber,
    String? birthDate,
    bool? isResident,
    String? pinfl,
    String? passData,
    double? threshold,
  }) async {
    try {
      // So'rov tanasi
      final Map<String, dynamic> requestBody = {};

      if (phoneNumber != null) requestBody['phone_number'] = phoneNumber;
      if (birthDate != null) requestBody['birth_date'] = birthDate;
      if (isResident != null) requestBody['is_resident'] = isResident;
      if (pinfl != null) requestBody['pinfl'] = pinfl;
      if (passData != null) requestBody['pass_data'] = passData;
      if (threshold != null) requestBody['threshold'] = threshold;

      final response = await http.post(
        Uri.parse('https://myid.uz/api/v2/sdk/sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'session_id': data['session_id'],
          'data': data,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': 'Sessiya yaratishda xatolik: ${response.statusCode}',
          'error_details': errorData,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Tarmoq xatosi: ${e.toString()}'};
    }
  }

  // Sessiya yaratish va MyID SDK'ni ishga tushirish (to'liq jarayon)
  // Bu funksiya:
  // 1. Access token oladi
  // 2. Sessiya yaratadi
  // 3. Session ID ni qaytaradi (MyID SDK uchun)
  static Future<Map<String, dynamic>> createSessionWithToken({
    required String clientId,
    required String clientSecret,
    String? phoneNumber,
    String? birthDate,
    bool? isResident,
    String? pinfl,
    String? passData,
    double? threshold,
  }) async {
    try {
      // 1. Access token olish
      final tokenResult = await getAccessToken(
        clientId: clientId,
        clientSecret: clientSecret,
      );

      if (tokenResult['success'] != true) {
        return {
          'success': false,
          'error': 'Access token olishda xatolik',
          'details': tokenResult,
        };
      }

      final accessToken = tokenResult['access_token'] as String;

      // 2. Sessiya yaratish
      final sessionResult = await createSession(
        accessToken: accessToken,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        isResident: isResident,
        pinfl: pinfl,
        passData: passData,
        threshold: threshold,
      );

      if (sessionResult['success'] != true) {
        return {
          'success': false,
          'error': 'Sessiya yaratishda xatolik',
          'details': sessionResult,
        };
      }

      // 3. Muvaffaqiyatli natija
      return {
        'success': true,
        'session_id': sessionResult['session_id'],
        'access_token': accessToken,
        'message':
            'Sessiya muvaffaqiyatli yaratildi. MyID SDK ishga tushirishingiz mumkin.',
      };
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
