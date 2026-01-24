import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import '../config/myid_config.dart' as app_config;

/// MyID To'liq Autentifikatsiya Oqimi
///
/// Bu servis MyID SDK'ni to'g'ri integratsiya qiladi va quyidagi qadamlarni bajaradi:
/// 1. Backend'dan sessiya olish
/// 2. MyID SDK'ni sessiya bilan ishga tushirish
/// 3. Foydalanuvchi ma'lumotlarini olish
/// 4. Ma'lumotlarni saqlash
class MyIdCompleteFlow {
  /// Backend server URL
  static const String _backendUrl =
      'https://greenmarket-backend-lilac.vercel.app';

  /// MyID client hash
  static const String _clientHash = app_config.MyIDConfig.clientHash;

  /// MyID client hash ID
  static const String _clientHashId = app_config.MyIDConfig.clientHashId;

  /// Pasport ma'lumotlari bilan to'liq autentifikatsiya oqimi
  ///
  /// Bu metod pasport ma'lumotlari bilan sessiya yaratadi va foydalanuvchi
  /// ma'lumotlarini oladi. KYC va bank xizmatlari uchun ishlatiladi.
  ///
  /// Parameters:
  /// - [passportSeries]: Pasport seriyasi (masalan: "AA")
  /// - [passportNumber]: Pasport raqami (masalan: "1234567")
  /// - [birthDate]: Tug'ilgan sana (YYYY-MM-DD formatida)
  /// - [onStatusUpdate]: Har bir qadamda status yangilanadi
  ///
  /// Returns:
  /// - `success`: true - autentifikatsiya muvaffaqiyatli
  /// - `profile`: Foydalanuvchining to'liq profili
  /// - `error`: Xato xabari (muvaffaqiyatsiz bo'lsa)
  static Future<Map<String, dynamic>> completeAuthFlowWithPassport({
    required String passportSeries,
    required String passportNumber,
    required String birthDate,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      // 1-qadam: Pasport ma'lumotlari bilan sessiya yaratish
      onStatusUpdate?.call(
        'Pasport ma\'lumotlari bilan sessiya yaratilmoqda...',
      );
      debugPrint(
        '📤 [1/4] Pasport ma\'lumotlari bilan sessiya yaratilmoqda...',
      );

      final sessionResult = await _getSessionWithPassport(
        passportSeries: passportSeries,
        passportNumber: passportNumber,
        birthDate: birthDate,
      );

      if (sessionResult['success'] != true) {
        return {
          'success': false,
          'error': sessionResult['error'] ?? 'Sessiya olinmadi',
        };
      }

      final sessionId = sessionResult['session_id'];
      debugPrint('✅ [1/4] Sessiya olindi: $sessionId');
      onStatusUpdate?.call('Sessiya olindi');

      // 2-qadam: MyID SDK'ni ishga tushirish
      onStatusUpdate?.call('MyID SDK ishga tushirilmoqda...');
      debugPrint('📤 [2/4] MyID SDK ishga tushirilmoqda...');

      final sdkResult = await _startMyIdSdk(sessionId);
      if (sdkResult['success'] != true) {
        return {'success': false, 'error': sdkResult['error'] ?? 'SDK xatosi'};
      }

      final code = sdkResult['code'];
      debugPrint('✅ [2/4] SDK muvaffaqiyatli: $code');
      onStatusUpdate?.call('SDK muvaffaqiyatli');

      // 3-qadam: Foydalanuvchi ma'lumotlarini olish
      onStatusUpdate?.call('Foydalanuvchi profili olinmoqda...');
      debugPrint('📤 [3/4] Foydalanuvchi profili olinmoqda...');

      final userData = await _getUserData(code);
      if (userData['success'] != true) {
        return {
          'success': false,
          'error': userData['error'] ?? 'Ma\'lumot olinmadi',
        };
      }

      debugPrint('✅ [3/4] Profil olindi');
      onStatusUpdate?.call('Profil olindi');

      // 4-qadam: Muvaffaqiyatli
      onStatusUpdate?.call('KYC muvaffaqiyatli tugadi');
      debugPrint('✅ [4/4] KYC muvaffaqiyatli tugadi');

      return {'success': true, 'code': code, 'profile': userData['data']};
    } catch (e) {
      debugPrint('❌ Xatolik: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Bo'sh sessiya bilan to'liq autentifikatsiya oqimi
  ///
  /// Bu metod bo'sh sessiya yaratadi va foydalanuvchi ma'lumotlarini oladi.
  /// Oddiy identifikatsiya uchun ishlatiladi.
  static Future<Map<String, dynamic>> completeAuthFlow({
    Function(String)? onStatusUpdate,
  }) async {
    try {
      // 1-qadam: Backend'dan sessiya olish
      onStatusUpdate?.call('Backend\'dan sessiya olinmoqda...');
      debugPrint('📤 [1/4] Backend\'dan sessiya olinmoqda...');

      final sessionResult = await _getSessionFromBackend();
      if (sessionResult['success'] != true) {
        return {
          'success': false,
          'error': sessionResult['error'] ?? 'Sessiya olinmadi',
        };
      }

      final sessionId = sessionResult['session_id'];
      debugPrint('✅ [1/4] Sessiya olindi: $sessionId');
      onStatusUpdate?.call('Sessiya olindi');

      // 2-qadam: MyID SDK'ni ishga tushirish
      onStatusUpdate?.call('MyID SDK ishga tushirilmoqda...');
      debugPrint('📤 [2/4] MyID SDK ishga tushirilmoqda...');

      final sdkResult = await _startMyIdSdk(sessionId);
      if (sdkResult['success'] != true) {
        return {'success': false, 'error': sdkResult['error'] ?? 'SDK xatosi'};
      }

      final code = sdkResult['code'];
      debugPrint('✅ [2/4] SDK muvaffaqiyatli: $code');
      onStatusUpdate?.call('SDK muvaffaqiyatli');

      // 3-qadam: Foydalanuvchi ma'lumotlarini olish
      onStatusUpdate?.call('Foydalanuvchi ma\'lumotlari olinmoqda...');
      debugPrint('📤 [3/4] Foydalanuvchi ma\'lumotlari olinmoqda...');

      final userData = await _getUserData(code);
      if (userData['success'] != true) {
        return {
          'success': false,
          'error': userData['error'] ?? 'Ma\'lumot olinmadi',
        };
      }

      debugPrint('✅ [3/4] Ma\'lumotlar olindi');
      onStatusUpdate?.call('Ma\'lumotlar olindi');

      // 4-qadam: Muvaffaqiyatli
      onStatusUpdate?.call('Autentifikatsiya muvaffaqiyatli');
      debugPrint('✅ [4/4] Autentifikatsiya muvaffaqiyatli');

      return {'success': true, 'code': code, 'user_data': userData['data']};
    } catch (e) {
      debugPrint('❌ Xatolik: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Pasport ma'lumotlari bilan backend'dan sessiya olish
  static Future<Map<String, dynamic>> _getSessionWithPassport({
    required String passportSeries,
    required String passportNumber,
    required String birthDate,
  }) async {
    try {
      // Pasport ma'lumotlarini birlashtiramiz (AA1234567 formatida)
      final passData = '$passportSeries$passportNumber';

      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/myid/create-session-with-passport'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'pass_data': passData, 'birth_date': birthDate}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📥 Backend javob: ${response.body}');

        if (data['success'] == true && data['data'] != null) {
          return {'success': true, 'session_id': data['data']['session_id']};
        }
        return {'success': false, 'error': 'Sessiya ma\'lumotlari noto\'g\'ri'};
      } else {
        return {
          'success': false,
          'error': 'Backend xatosi: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Backend bilan aloqa xatosi: $e'};
    }
  }

  /// Backend'dan sessiya olish
  static Future<Map<String, dynamic>> _getSessionFromBackend() async {
    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/myid/create-session'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📥 Backend javob: ${response.body}');

        // Backend javobini tekshirish
        if (data['success'] == true && data['data'] != null) {
          return {'success': true, 'session_id': data['data']['session_id']};
        }
        return {'success': false, 'error': 'Sessiya ma\'lumotlari noto\'g\'ri'};
      } else {
        return {
          'success': false,
          'error': 'Backend xatosi: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Backend bilan aloqa xatosi: $e'};
    }
  }

  /// MyID SDK'ni ishga tushirish
  static Future<Map<String, dynamic>> _startMyIdSdk(String sessionId) async {
    try {
      final config = MyIdConfig(
        sessionId: sessionId,
        clientHash: _clientHash,
        clientHashId: _clientHashId,
        environment: MyIdEnvironment.DEBUG,
        entryType: MyIdEntryType.IDENTIFICATION,
        residency: MyIdResidency.USER_DEFINED,
        locale: MyIdLocale.UZBEK,
      );

      debugPrint('🚀 SDK konfiguratsiyasi: $config');

      final result = await MyIdClient.start(
        config: config,
        iosAppearance: const MyIdIOSAppearance(),
      );

      debugPrint('📥 SDK natijasi: $result');

      return {'success': true, 'code': result.code, 'result': result};
    } catch (e) {
      return {'success': false, 'error': 'SDK xatosi: $e'};
    }
  }

  /// Foydalanuvchi ma'lumotlarini olish
  static Future<Map<String, dynamic>> _getUserData(String code) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/myid/get-user-info'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'code': code}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📥 Foydalanuvchi ma\'lumotlari: ${response.body}');

        if (data['success'] == true) {
          return {'success': true, 'data': data['data']};
        }
        return {'success': false, 'error': 'Ma\'lumot olinmadi'};
      } else {
        return {
          'success': false,
          'error': 'Backend xatosi: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Ma\'lumot olishda xato: $e'};
    }
  }
}
