import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import '../config/myid_config.dart' as app_config;

/// MyID Backend Client - Backend server bilan ishlash uchun
/// Bu servis backend'dan sessiya oladi va SDK'ga beradi
class MyIdBackendClient {
  // Backend server URL
  static const String _backendUrl =
      'https://greenmarket-backend-lilac.vercel.app';

  // MyID credentials
  static const String _clientHash = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5wQYaS8i1b0Rj5wuJLhI
yDuTW/WoWB/kRbJCBHFLyFTxETADNa/CU+xw0moN9X10+MVD5kRMinMRQpGUVCrU
XjUAEjwbdaCSLR6suRYI1EfDMQ5XFdJsfkAlNzZyyfBlif4OA4qxaMtdyvJCa/8n
wHn2KC89BNhqBQMre7iLaW8Z9bArSulSxBJzbzPjd7Jkg4ccQ47bVyjEKBcu/1KX
Ud/audUr1WsUpBf9yvgSTDRG2cuVXpMGEBJAqrsCS3RtIt7pEnGtr5FsB+UmBec9
Ei97fK2LcVfWpc/m7WjWMz3mku/pmhSjC6Vl6dlOrP1dv/fJkhfh3axzXtZoxgV1
QwIDAQAB
-----END PUBLIC KEY-----''';

  /// 1. Backend'dan bo'sh sessiya olish
  static Future<Map<String, dynamic>> createEmptySession() async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/myid/create-session'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {'success': true, 'session_id': data['data']['session_id']};
        } else {
          return {'success': false, 'error': data['error']};
        }
      } else {
        return {
          'success': false,
          'error': 'Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 2. Backend'dan pasport bilan sessiya olish
  static Future<Map<String, dynamic>> createSessionWithPassport({
    required String passportSeries,
    required String passportNumber,
    required String birthDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/myid/create-session-with-passport'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'passport_series': passportSeries,
          'passport_number': passportNumber,
          'birth_date': birthDate,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {'success': true, 'session_id': data['data']['session_id']};
        } else {
          return {'success': false, 'error': data['error']};
        }
      } else {
        return {
          'success': false,
          'error': 'Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 3. MyID SDK ishga tushirish
  static Future<Map<String, dynamic>> startSDK({
    required String sessionId,
    bool forcePassportScreen = false,
  }) async {
    try {
      final result = await MyIdClient.start(
        config: MyIdConfig(
          sessionId: sessionId,
          clientHash: _clientHash,
          clientHashId: app_config.MyIDConfig.clientHashId,
          environment: MyIdEnvironment.DEBUG, // Test muhitida ishlash
          entryType: MyIdEntryType.IDENTIFICATION,
          locale: MyIdLocale.UZBEK,
          // MUHIM: residency = USER_DEFINED bo'lsa, SDK pasport ekranini ko'rsatadi
          residency: forcePassportScreen
              ? MyIdResidency.USER_DEFINED
              : MyIdResidency.RESIDENT,
        ),
        iosAppearance: const MyIdIOSAppearance(),
      );

      return {
        'success': result.code == '0',
        'code': result.code,
        'result': result,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// TO'LIQ JARAYON - Backend orqali
  /// 1. Backend → bo'sh sessiya yaratadi
  /// 2. Mobile → SDK'ni ishga tushiradi
  /// 3. SDK → pasport ekranini ko'rsatadi
  /// 4. Backend → foydalanuvchini saqlaydi
  static Future<Map<String, dynamic>> completeAuthFlowWithBackend({
    Function(String)? onStatusUpdate,
  }) async {
    try {
      // 1. Backend'dan bo'sh sessiya olish
      onStatusUpdate?.call('Backend\'dan sessiya olinmoqda...');
      final sessionResult = await createEmptySession();

      if (sessionResult['success'] != true) {
        return {
          'success': false,
          'error': 'Sessiya yaratishda xatolik',
          'details': sessionResult,
        };
      }

      final sessionId = sessionResult['session_id'] as String;

      // 2. SDK'ni ishga tushirish (pasport ekrani bilan)
      onStatusUpdate?.call('MyID SDK ishga tushirilmoqda...');
      final sdkResult = await startSDK(
        sessionId: sessionId,
        forcePassportScreen: true, // Pasport ekranini majburiy ko'rsatish
      );

      if (sdkResult['success'] != true) {
        return {'success': false, 'error': 'SDK xatosi', 'details': sdkResult};
      }

      // 3. Foydalanuvchini backend'ga saqlash
      onStatusUpdate?.call('Foydalanuvchi saqlanmoqda...');
      final registerResult = await _registerUser(sessionId);

      // 4. Muvaffaqiyatli
      return {
        'success': true,
        'session_id': sessionId,
        'code': sdkResult['code'],
        'user_registered': registerResult['success'],
        'message': 'Muvaffaqiyatli autentifikatsiya!',
      };
    } catch (e) {
      return {'success': false, 'error': 'Kutilmagan xatolik: ${e.toString()}'};
    }
  }

  /// Foydalanuvchini backend'ga saqlash
  static Future<Map<String, dynamic>> _registerUser(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'session_id': sessionId,
          'profile_data': null, // Keyinroq to'ldiriladi
          'passport_data': null,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
