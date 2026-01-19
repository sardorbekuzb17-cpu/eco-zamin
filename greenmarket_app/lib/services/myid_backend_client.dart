import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import '../config/myid_config.dart' as app_config;

/// MyID Backend Client
///
/// Bu servis backend server bilan ishlash va MyID SDK'ni boshqarish uchun
/// mo'ljallangan. Asosiy vazifalar:
/// - Backend'dan sessiya olish
/// - MyID SDK'ni ishga tushirish
/// - To'liq autentifikatsiya oqimini amalga oshirish
/// - Foydalanuvchi ma'lumotlarini olish
///
/// Barcha metodlar asinxron va `Map<String, dynamic>` qaytaradi.
class MyIdBackendClient {
  /// Backend server URL manzili
  /// Production muhitida Vercel'da joylashgan
  static const String _backendUrl =
      'https://greenmarket-backend-lilac.vercel.app';

  /// MyID client hash - SDK konfiguratsiyasi uchun zarur
  static const String _clientHash = app_config.MyIDConfig.clientHash;

  /// MyID client hash ID - SDK konfiguratsiyasi uchun zarur
  static const String _clientHashId = app_config.MyIDConfig.clientHashId;

  /// Backend'dan sessiya olish
  ///
  /// Bu metod backend orqali MyID'da bo'sh sessiya yaratadi.
  /// Sessiya MyID SDK'ni ishga tushirish uchun zarur.
  ///
  /// Returns:
  /// - `success`: true - sessiya muvaffaqiyatli olindi
  /// - `data`: MyID API javobini o'z ichiga oladi
  ///   - `data.session_id`: Sessiya identifikatori
  ///   - `data.expires_in`: Sessiya amal qilish muddati
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  ///
  /// Example:
  /// ```dart
  /// final result = await MyIdBackendClient.getSession();
  /// if (result['success'] == true) {
  ///   final sessionId = result['data']['data']['session_id'];
  /// }
  /// ```
  static Future<Map<String, dynamic>> getSession() async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/myid/create-session'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Status code: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Pasport ma'lumotlari bilan sessiya yaratish
  ///
  /// Bu metod pasport ma'lumotlari bilan sessiya yaratadi.
  /// Pasport ma'lumotlari berilgan bo'lsa, SDK foydalanuvchidan
  /// faqat yuz rasmini oladi.
  ///
  /// Parameters:
  /// - [phoneNumber]: Telefon raqami (ixtiyoriy)
  /// - [birthDate]: Tug'ilgan sana (ixtiyoriy, YYYY-MM-DD)
  /// - [isResident]: Rezidentmi (ixtiyoriy)
  /// - [passData]: Pasport ma'lumotlari (ixtiyoriy, masalan: "AA1234567")
  /// - [threshold]: Yuz tanish aniqlik darajasi (ixtiyoriy, 0.5 - 0.99)
  ///
  /// Returns:
  /// - `success`: true - sessiya muvaffaqiyatli yaratildi
  /// - `data`: Sessiya ma'lumotlari
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  ///
  /// Example:
  /// ```dart
  /// final result = await MyIdBackendClient.createSessionWithPassport(
  ///   passData: 'AA1234567',
  ///   birthDate: '1990-01-01',
  /// );
  /// ```
  static Future<Map<String, dynamic>> createSessionWithPassport({
    String? phoneNumber,
    String? birthDate,
    bool? isResident,
    String? passData,
    double? threshold,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (phoneNumber != null) body['phone_number'] = phoneNumber;
      if (birthDate != null) body['birth_date'] = birthDate;
      if (isResident != null) body['is_resident'] = isResident;
      if (passData != null) body['pass_data'] = passData;
      if (threshold != null) body['threshold'] = threshold;

      final response = await http.post(
        Uri.parse('$_backendUrl/api/myid/create-session-with-passport'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Status code: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// MyID SDK'ni ishga tushirish
  ///
  /// Bu metod MyID SDK'ni berilgan sessiya ID bilan ishga tushiradi.
  /// SDK foydalanuvchidan yuz rasmini oladi va natijani qaytaradi.
  ///
  /// SDK konfiguratsiyasi:
  /// - Environment: PRODUCTION
  /// - Entry Type: IDENTIFICATION
  /// - Locale: UZBEK
  /// - Residency: USER_DEFINED (pasport ekranini ko'rsatish)
  ///
  /// Parameters:
  /// - [sessionId]: Sessiya identifikatori (getSession'dan olingan)
  ///
  /// Returns:
  /// - `success`: true - SDK muvaffaqiyatli yakunlandi (code == '0')
  /// - `code`: SDK natija kodi ('0' - muvaffaqiyatli, '1' - bekor qilindi, '2'/'3' - xato)
  /// - `base64`: Yuz rasmi (base64 formatida)
  /// - `result`: To'liq SDK natijasi
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  ///
  /// Example:
  /// ```dart
  /// final result = await MyIdBackendClient.startSDK(
  ///   sessionId: 'session_id_from_backend',
  /// );
  /// if (result['success'] == true) {
  ///   final code = result['code'];
  ///   print('SDK code: $code');
  /// }
  /// ```
  static Future<Map<String, dynamic>> startSDK({
    required String sessionId,
  }) async {
    try {
      debugPrint('🚀 SDK ishga tushirilmoqda, session_id: $sessionId');

      final config = MyIdConfig(
        sessionId: sessionId,
        clientHash: _clientHash,
        clientHashId: _clientHashId,
        environment: MyIdEnvironment.DEBUG,
        entryType: MyIdEntryType.IDENTIFICATION,
        locale: MyIdLocale.UZBEK,
        residency: MyIdResidency.USER_DEFINED,
      );

      final result = await MyIdClient.start(
        config: config,
        iosAppearance: const MyIdIOSAppearance(),
      );

      debugPrint(
        '✅ SDK natija: code=${result.code}, base64=${result.base64?.substring(0, 20)}...',
      );

      return {
        'success': result.code == '0',
        'code': result.code,
        'base64': result.base64,
        'result': result,
      };
    } catch (e) {
      debugPrint('❌ SDK xatosi: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// To'liq autentifikatsiya oqimi (pasport ma'lumotlari bilan)
  ///
  /// Bu metod to'liq MyID autentifikatsiya jarayonini amalga oshiradi:
  /// 1. Pasport ma'lumotlari bilan sessiya yaratadi
  /// 2. MyID SDK'ni ishga tushiradi
  /// 3. SDK'dan olingan code bilan foydalanuvchi ma'lumotlarini oladi
  ///
  /// Parameters:
  /// - [passportData]: Pasport ma'lumotlari
  ///   - `pass_data`: Pasport seriyasi va raqami
  ///   - `birth_date`: Tug'ilgan sana
  /// - [onStatusUpdate]: Holat yangilanishlarini kuzatish uchun callback (ixtiyoriy)
  ///
  /// Returns:
  /// - `success`: true - jarayon muvaffaqiyatli
  /// - `session_id`: Sessiya ID
  /// - `code`: SDK natija kodi
  /// - `user_data`: Foydalanuvchi ma'lumotlari
  /// - `message`: Holat xabari
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  ///
  /// Example:
  /// ```dart
  /// final result = await MyIdBackendClient.completeAuthFlowWithPassport(
  ///   passportData: {
  ///     'pass_data': 'AA1234567',
  ///     'birth_date': '1990-01-01',
  ///   },
  ///   onStatusUpdate: (status) => print(status),
  /// );
  /// ```
  static Future<Map<String, dynamic>> completeAuthFlowWithPassport({
    required Map<String, dynamic> passportData,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      // 1. Backend'dan pasport bilan sessiya olish
      onStatusUpdate?.call('Pasport bilan sessiya yaratilmoqda...');
      final sessionResult = await createSessionWithPassport(
        passData: passportData['pass_data'],
        birthDate: passportData['birth_date'],
      );

      if (sessionResult['success'] != true) {
        return {
          'success': false,
          'error': 'Sessiya olishda xatolik: ${sessionResult['error']}',
          'details': sessionResult,
        };
      }

      // Session ID olish
      final outerData = sessionResult['data'];
      if (outerData == null) {
        return {
          'success': false,
          'error': 'Data null',
          'details': sessionResult,
        };
      }

      final innerData = outerData['data'];
      final sessionId =
          (innerData != null
                  ? innerData['session_id']
                  : outerData['session_id'])
              as String?;

      if (sessionId == null || sessionId.isEmpty) {
        return {
          'success': false,
          'error': 'Session ID topilmadi',
          'details': sessionResult,
        };
      }

      // 2. SDK'ni ishga tushirish
      onStatusUpdate?.call('MyID SDK ishga tushirilmoqda...');
      final sdkResult = await startSDK(sessionId: sessionId);

      if (sdkResult['success'] != true) {
        return {
          'success': false,
          'error':
              'SDK xatosi: ${sdkResult['error'] ?? sdkResult['code'] ?? 'Noma\'lum'}',
          'details': sdkResult,
        };
      }

      final code = sdkResult['code'] as String?;
      if (code == null || code.isEmpty) {
        return {
          'success': false,
          'error': 'SDK code null yoki bo\'sh',
          'details': sdkResult,
        };
      }

      // 3. Backend'ga code yuborish va foydalanuvchi ma'lumotlarini olish
      onStatusUpdate?.call('Foydalanuvchi ma\'lumotlari olinmoqda...');
      final userInfoResult = await getUserInfo(code);

      if (userInfoResult['success'] != true) {
        return {
          'success': false,
          'error': 'Foydalanuvchi ma\'lumotlarini olishda xatolik',
          'details': userInfoResult,
        };
      }

      // 4. Muvaffaqiyatli
      return {
        'success': true,
        'session_id': sessionId,
        'code': code,
        'user_data': userInfoResult['data'],
        'message': 'Muvaffaqiyatli autentifikatsiya!',
      };
    } catch (e) {
      return {'success': false, 'error': 'Kutilmagan xatolik: ${e.toString()}'};
    }
  }

  /// To'liq autentifikatsiya oqimi (bo'sh sessiya bilan)
  ///
  /// Bu metod to'liq MyID autentifikatsiya jarayonini amalga oshiradi:
  /// 1. Backend'dan bo'sh sessiya oladi
  /// 2. MyID SDK'ni ishga tushiradi (SDK o'zi pasport so'raydi)
  /// 3. SDK'dan olingan code bilan foydalanuvchi ma'lumotlarini oladi
  ///
  /// Parameters:
  /// - [onStatusUpdate]: Holat yangilanishlarini kuzatish uchun callback (ixtiyoriy)
  ///
  /// Returns:
  /// - `success`: true - jarayon muvaffaqiyatli
  /// - `session_id`: Sessiya ID
  /// - `code`: SDK natija kodi
  /// - `user_data`: Foydalanuvchi ma'lumotlari
  /// - `message`: Holat xabari
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  ///
  /// Example:
  /// ```dart
  /// final result = await MyIdBackendClient.completeAuthFlow(
  ///   onStatusUpdate: (status) => print(status),
  /// );
  /// if (result['success'] == true) {
  ///   final userData = result['user_data'];
  ///   print('Foydalanuvchi: ${userData['profile']['first_name']}');
  /// }
  /// ```
  static Future<Map<String, dynamic>> completeAuthFlow({
    Function(String)? onStatusUpdate,
  }) async {
    try {
      // 1. Backend'dan sessiya olish
      onStatusUpdate?.call('Backend\'dan sessiya olinmoqda...');
      final sessionResult = await getSession();

      if (sessionResult['success'] != true) {
        return {
          'success': false,
          'error': 'Sessiya olishda xatolik: ${sessionResult['error']}',
          'details': sessionResult,
        };
      }

      final outerData = sessionResult['data'];
      if (outerData == null) {
        return {
          'success': false,
          'error': 'Outer data null',
          'details': sessionResult,
        };
      }

      // MyID API javobida data ichida session_id bor
      final innerData = outerData['data'];
      if (innerData == null) {
        final sessionId = outerData['session_id'] as String?;
        if (sessionId == null || sessionId.isEmpty) {
          return {
            'success': false,
            'error': 'Session ID topilmadi',
            'details': sessionResult,
          };
        }

        // 2. SDK'ni ishga tushirish
        onStatusUpdate?.call('MyID SDK ishga tushirilmoqda...');
        final sdkResult = await startSDK(sessionId: sessionId);

        if (sdkResult['success'] != true) {
          return {
            'success': false,
            'error':
                'SDK xatosi: ${sdkResult['error'] ?? sdkResult['code'] ?? 'Noma\'lum'}',
            'details': sdkResult,
          };
        }

        final code = sdkResult['code'] as String?;
        if (code == null || code.isEmpty) {
          return {
            'success': false,
            'error': 'SDK code null yoki bo\'sh',
            'details': sdkResult,
          };
        }

        // 3. Backend'ga code yuborish va foydalanuvchi ma'lumotlarini olish
        onStatusUpdate?.call('Foydalanuvchi ma\'lumotlari olinmoqda...');
        final userInfoResult = await getUserInfo(code);

        if (userInfoResult['success'] != true) {
          return {
            'success': false,
            'error': 'Foydalanuvchi ma\'lumotlarini olishda xatolik',
            'details': userInfoResult,
          };
        }

        // 4. Muvaffaqiyatli
        return {
          'success': true,
          'session_id': sessionId,
          'code': code,
          'user_data': userInfoResult['data'],
          'message': 'Muvaffaqiyatli autentifikatsiya!',
        };
      }

      // Agar data.data bor bo'lsa
      final sessionId = innerData['session_id'] as String?;
      if (sessionId == null || sessionId.isEmpty) {
        return {
          'success': false,
          'error': 'Session ID null yoki bo\'sh',
          'details': sessionResult,
        };
      }

      // 2. SDK'ni ishga tushirish
      onStatusUpdate?.call('MyID SDK ishga tushirilmoqda...');
      final sdkResult = await startSDK(sessionId: sessionId);

      if (sdkResult['success'] != true) {
        return {
          'success': false,
          'error':
              'SDK xatosi: ${sdkResult['error'] ?? sdkResult['code'] ?? 'Noma\'lum'}',
          'details': sdkResult,
        };
      }

      final code = sdkResult['code'] as String?;
      if (code == null || code.isEmpty) {
        return {
          'success': false,
          'error': 'SDK code null yoki bo\'sh',
          'details': sdkResult,
        };
      }

      // 3. Backend'ga code yuborish va foydalanuvchi ma'lumotlarini olish
      onStatusUpdate?.call('Foydalanuvchi ma\'lumotlari olinmoqda...');
      final userInfoResult = await getUserInfo(code);

      if (userInfoResult['success'] != true) {
        return {
          'success': false,
          'error': 'Foydalanuvchi ma\'lumotlarini olishda xatolik',
          'details': userInfoResult,
        };
      }

      // 4. Muvaffaqiyatli
      return {
        'success': true,
        'session_id': sessionId,
        'code': code,
        'user_data': userInfoResult['data'],
        'message': 'Muvaffaqiyatli autentifikatsiya!',
      };
    } catch (e) {
      return {'success': false, 'error': 'Kutilmagan xatolik: ${e.toString()}'};
    }
  }

  /// Foydalanuvchi ma'lumotlarini olish
  ///
  /// SDK'dan olingan code yordamida backend orqali foydalanuvchi
  /// shaxsiy ma'lumotlarini oladi.
  ///
  /// Parameters:
  /// - [code]: MyID SDK'dan olingan natija kodi
  ///
  /// Returns:
  /// - `success`: true - ma'lumotlar muvaffaqiyatli olindi
  /// - `data`: Foydalanuvchi ma'lumotlari
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  ///
  /// Example:
  /// ```dart
  /// final result = await MyIdBackendClient.getUserInfo('code_from_sdk');
  /// if (result['success'] == true) {
  ///   final profile = result['data']['profile'];
  ///   print('Ism: ${profile['first_name']}');
  /// }
  /// ```
  static Future<Map<String, dynamic>> getUserInfo(String code) async {
    try {
      debugPrint('📤 Backend\'ga code yuborilmoqda: $code');

      final response = await http.post(
        Uri.parse('$_backendUrl/api/myid/get-user-info'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': code}),
      );

      debugPrint('📥 Backend javob berdi: ${response.statusCode}');
      debugPrint('📥 Backend javob body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Status code: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      debugPrint('❌ getUserInfo xatosi: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Sessiya natijasini olish
  ///
  /// SDK tugagandan keyin sessiya natijasini backend orqali oladi.
  /// Bu metod SDK'dan code olish imkoni bo'lmagan hollarda ishlatiladi.
  ///
  /// Parameters:
  /// - [sessionId]: Sessiya identifikatori
  ///
  /// Returns:
  /// - `success`: true - natija muvaffaqiyatli olindi
  /// - `data`: Sessiya natijasi
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  ///
  /// Example:
  /// ```dart
  /// final result = await MyIdBackendClient.getSessionResult('session_id');
  /// if (result['success'] == true) {
  ///   final sessionData = result['data'];
  /// }
  /// ```
  static Future<Map<String, dynamic>> getSessionResult(String sessionId) async {
    try {
      debugPrint('📤 Backend\'ga session_id yuborilmoqda: $sessionId');

      final response = await http.post(
        Uri.parse('$_backendUrl/api/myid/get-session-result'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'session_id': sessionId}),
      );

      debugPrint('📥 Backend javob berdi: ${response.statusCode}');
      debugPrint('📥 Backend javob body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Status code: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      debugPrint('❌ getSessionResult xatosi: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
