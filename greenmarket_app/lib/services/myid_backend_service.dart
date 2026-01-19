import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// MyID Backend Service
///
/// Bu servis GreenMarket backend serveri bilan aloqa qiladi va MyID
/// integratsiyasi uchun zarur funksiyalarni taqdim etadi.
///
/// Asosiy funksiyalar:
/// - Bo'sh sessiya yaratish (SDK o'zi pasport so'raydi)
/// - Pasport ma'lumotlarini tekshirish
/// - OAuth access token olish
/// - Sessiya yaratish (PINFL yoki pasport bilan)
/// - Backend health check
///
/// Barcha so'rovlar HTTPS protokoli orqali amalga oshiriladi.
class MyIdBackendService {
  /// Backend server URL manzili
  /// Production muhitida Vercel'da joylashgan
  static const String backendUrl =
      'https://greenmarket-backend-lilac.vercel.app';

  /// Bo'sh sessiya yaratish
  ///
  /// Bu metod backend orqali MyID'da bo'sh sessiya yaratadi.
  /// Bo'sh sessiya - pasport ma'lumotlari kiritilmagan sessiya.
  /// MyID SDK o'zi foydalanuvchidan pasport ma'lumotlarini so'raydi.
  ///
  /// Returns:
  /// - `success`: true - sessiya muvaffaqiyatli yaratildi
  /// - `data`: MyID API javobini o'z ichiga oladi
  ///   - `data.session_id`: Sessiya identifikatori (SDK uchun zarur)
  ///   - `data.expires_in`: Sessiya amal qilish muddati (sekundlarda)
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  ///
  /// Example:
  /// ```dart
  /// final result = await MyIdBackendService.createEmptySession();
  /// if (result['success'] == true) {
  ///   final sessionId = result['data']['data']['session_id'];
  ///   print('Session ID: $sessionId');
  /// }
  /// ```
  static Future<Map<String, dynamic>> createEmptySession() async {
    try {
      debugPrint(
        '📤 Backend\'ga so\'rov yuborilmoqda: $backendUrl/api/myid/create-session',
      );

      final response = await http.post(
        Uri.parse('$backendUrl/api/myid/create-session'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );

      debugPrint('📥 Backend javob berdi: ${response.statusCode}');
      debugPrint('📥 Backend javob body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Backend javobini tekshirish
        // Format: {success: true, session_id: "...", data: {...}}
        if (data['session_id'] != null) {
          return {
            'success': true,
            'session_id': data['session_id'],
            'data': data,
          };
        }
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
      debugPrint('❌ createEmptySession xatosi: $e');
      return {'success': false, 'error': 'Xatolik: ${e.toString()}'};
    }
  }

  /// Pasport ma'lumotlarini MyID orqali tekshirish
  ///
  /// Bu metod foydalanuvchi pasport ma'lumotlarini MyID tizimida tekshiradi.
  ///
  /// Parameters:
  /// - [passportSeries]: Pasport seriyasi (masalan: "AA")
  /// - [passportNumber]: Pasport raqami (masalan: "1234567")
  /// - [birthDate]: Tug'ilgan sana (YYYY-MM-DD formatida)
  ///
  /// Returns:
  /// - `success`: true - pasport ma'lumotlari to'g'ri
  /// - `data`: Tekshirish natijasi
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  ///
  /// Example:
  /// ```dart
  /// final result = await MyIdBackendService.verifyPassport(
  ///   passportSeries: 'AA',
  ///   passportNumber: '1234567',
  ///   birthDate: '1990-01-01',
  /// );
  /// ```
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

  /// OAuth Access Token olish
  ///
  /// MyID API'dan OAuth 2.0 access token oladi. Token barcha MyID API
  /// so'rovlari uchun zarur va 7 kun (604800 soniya) amal qiladi.
  ///
  /// API: POST https://myid.uz/api/v1/auth/clients/access-token
  ///
  /// Parameters:
  /// - [clientId]: MyID client ID (shartnomadan olingan)
  /// - [clientSecret]: MyID client secret (shartnomadan olingan)
  ///
  /// Returns:
  /// - `success`: true - token muvaffaqiyatli olindi
  /// - `access_token`: JWT access token (512+ belgi)
  /// - `expires_in`: Token amal qilish muddati (sekundlarda, 604800 = 7 kun)
  /// - `token_type`: Token turi (odatda "Bearer")
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  ///
  /// Example:
  /// ```dart
  /// final result = await MyIdBackendService.getAccessToken(
  ///   clientId: 'your_client_id',
  ///   clientSecret: 'your_client_secret',
  /// );
  /// if (result['success'] == true) {
  ///   final token = result['access_token'];
  ///   print('Token: $token');
  /// }
  /// ```
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
        return {
          'success': true,
          'access_token': data['access_token'],
          'expires_in': data['expires_in'],
          'token_type': data['token_type'],
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

  /// Sessiya yaratish (PINFL yoki Pasport ma'lumotlari bilan)
  ///
  /// MyID SDK uchun sessiya yaratadi. Sessiya pasport ma'lumotlari bilan
  /// yoki bo'sh yaratilishi mumkin.
  ///
  /// API: POST {myid_host}/api/v2/sdk/sessions
  /// Authorization: Bearer {access_token}
  ///
  /// Parameters:
  /// - [accessToken]: MyID access token (getAccessToken'dan olingan)
  /// - [phoneNumber]: Telefon raqami (ixtiyoriy, +998901234567 formatida)
  /// - [birthDate]: Tug'ilgan sana (ixtiyoriy, YYYY-MM-DD formatida)
  /// - [isResident]: Rezidentmi (ixtiyoriy, standart: true)
  /// - [pinfl]: PINFL (ixtiyoriy, 14 raqam)
  /// - [passData]: Pasport seriyasi va raqami (ixtiyoriy, masalan: "AA1234567")
  /// - [threshold]: Yuz tanish aniqlik darajasi (ixtiyoriy, 0.5 - 0.99)
  ///
  /// Returns:
  /// - `success`: true - sessiya muvaffaqiyatli yaratildi
  /// - `session_id`: Sessiya identifikatori
  /// - `data`: To'liq sessiya ma'lumotlari
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  ///
  /// Example:
  /// ```dart
  /// final result = await MyIdBackendService.createSession(
  ///   accessToken: 'your_token',
  ///   passData: 'AA1234567',
  ///   birthDate: '1990-01-01',
  /// );
  /// ```
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

  /// Sessiya yaratish va MyID SDK'ni ishga tushirish (to'liq jarayon)
  ///
  /// Bu metod to'liq jarayonni amalga oshiradi:
  /// 1. Access token oladi
  /// 2. Sessiya yaratadi
  /// 3. Session ID ni qaytaradi (MyID SDK uchun)
  ///
  /// Parameters:
  /// - [clientId]: MyID client ID
  /// - [clientSecret]: MyID client secret
  /// - [phoneNumber]: Telefon raqami (ixtiyoriy)
  /// - [birthDate]: Tug'ilgan sana (ixtiyoriy)
  /// - [isResident]: Rezidentmi (ixtiyoriy)
  /// - [pinfl]: PINFL (ixtiyoriy)
  /// - [passData]: Pasport ma'lumotlari (ixtiyoriy)
  /// - [threshold]: Yuz tanish aniqlik darajasi (ixtiyoriy)
  ///
  /// Returns:
  /// - `success`: true - jarayon muvaffaqiyatli
  /// - `session_id`: Sessiya ID (SDK uchun zarur)
  /// - `access_token`: Access token
  /// - `message`: Holat xabari
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  ///
  /// Example:
  /// ```dart
  /// final result = await MyIdBackendService.createSessionWithToken(
  ///   clientId: 'your_client_id',
  ///   clientSecret: 'your_client_secret',
  ///   passData: 'AA1234567',
  ///   birthDate: '1990-01-01',
  /// );
  /// if (result['success'] == true) {
  ///   final sessionId = result['session_id'];
  ///   // MyID SDK'ni ishga tushirish
  /// }
  /// ```
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

  /// Backend health check
  ///
  /// Backend serverning ishlayotganligini tekshiradi.
  ///
  /// Returns:
  /// - `true`: Backend server ishlayapti
  /// - `false`: Backend server ishlamayapti yoki xatolik yuz berdi
  ///
  /// Example:
  /// ```dart
  /// final isHealthy = await MyIdBackendService.checkBackendHealth();
  /// if (isHealthy) {
  ///   print('Backend server ishlayapti');
  /// }
  /// ```
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
