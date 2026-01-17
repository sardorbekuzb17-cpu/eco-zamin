import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import '../config/myid_config.dart' as app_config;

/// MyID OAuth to'liq integratsiya servisi
/// Bu servis barcha OAuth jarayonini boshqaradi
class MyIdOAuthService {
  static const String _baseUrl = 'https://myid.uz';

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

  /// 1. Access Token olish
  /// Rasmda: "Primyer otveta" - access_token, expires_in, token_type
  static Future<Map<String, dynamic>> getAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/clients/access-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'client_id': app_config.MyIDConfig.clientId,
          'client_secret': app_config.MyIDConfig.clientSecret,
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
        return {
          'success': false,
          'error': 'Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 2. Sessiya yaratish
  /// Rasmda: "Sozdaniye sessii" - phone_number, birth_date, is_resident, pass_data, threshold
  /// MUHIM: Agar hech qanday parametr berilmasa, MyID SDK pasport kiritish ekranini ko'rsatadi
  static Future<Map<String, dynamic>> createSession({
    required String accessToken,
    String? phoneNumber,
    String? birthDate,
    bool? isResident,
    String? passData,
    String? pinfl,
    double? threshold,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {};

      // Faqat berilgan parametrlarni qo'shamiz
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        requestBody['phone_number'] = phoneNumber;
      }
      if (birthDate != null && birthDate.isNotEmpty) {
        requestBody['birth_date'] = birthDate;
      }
      if (isResident != null) {
        requestBody['is_resident'] = isResident;
      }
      if (passData != null && passData.isNotEmpty) {
        requestBody['pass_data'] = passData;
      }
      if (pinfl != null && pinfl.isNotEmpty) {
        requestBody['pinfl'] = pinfl;
      }
      if (threshold != null) {
        requestBody['threshold'] = threshold;
      }

      // Agar hech qanday parametr yo'q bo'lsa, bo'sh body yuboramiz
      // Bu MyID SDK ga pasport kiritish ekranini ko'rsatishni bildiradi

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v2/sdk/sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'session_id': data['session_id']};
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

  /// 3. MyID SDK ishga tushirish va foydalanuvchi identifikatsiyasi
  /// Rasmda: "Identification of user" - return result, image, code
  static Future<Map<String, dynamic>> identifyUser({
    required String sessionId,
    bool forcePassportScreen = false,
  }) async {
    try {
      final result = await MyIdClient.start(
        config: MyIdConfig(
          sessionId: sessionId,
          clientHash: _clientHash,
          clientHashId: app_config.MyIDConfig.clientHashId,
          environment: MyIdEnvironment.DEBUG,
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

  /// 4. Foydalanuvchi ma'lumotlarini olish
  /// Rasmda: "Polucheniye dannykh polzovatelya" - GET /sdk/sessions/{session_id}/profile
  static Future<Map<String, dynamic>> getUserProfile({
    required String accessToken,
    required String sessionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/sdk/sessions/$sessionId/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'profile': data,
          'data': data['data'],
          'comparison_value': data['comparison_value'],
          'pers_data': data['pers_data'],
          'pin_id': data['pin_id'],
        };
      } else if (response.statusCode == 4) {
        // Status code 4** - xato
        return {'success': false, 'error': 'Error message'};
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

  /// TO'LIQ JARAYON - Barcha qadamlarni birlashtiradi
  /// Bu funksiya rasmda ko'rsatilgan to'liq sequence diagram'ni amalga oshiradi
  static Future<Map<String, dynamic>> completeAuthFlow({
    String? phoneNumber,
    String? birthDate,
    bool? isResident,
    String? passData,
    String? pinfl,
    double? threshold,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      // 1. Access Token olish
      onStatusUpdate?.call('Access token olinmoqda...');
      final tokenResult = await getAccessToken();

      if (tokenResult['success'] != true) {
        return {
          'success': false,
          'error': 'Access token olishda xatolik',
          'details': tokenResult,
        };
      }

      final accessToken = tokenResult['access_token'] as String;

      // 2. Sessiya yaratish
      onStatusUpdate?.call('Sessiya yaratilmoqda...');
      final sessionResult = await createSession(
        accessToken: accessToken,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        isResident: isResident,
        passData: passData,
        pinfl: pinfl,
        threshold: threshold,
      );

      if (sessionResult['success'] != true) {
        return {
          'success': false,
          'error': 'Sessiya yaratishda xatolik',
          'details': sessionResult,
        };
      }

      final sessionId = sessionResult['session_id'] as String;

      // Bo'sh sessiya ekanligini tekshirish
      final isEmptySession =
          (phoneNumber == null || phoneNumber.isEmpty) &&
          (birthDate == null || birthDate.isEmpty) &&
          (passData == null || passData.isEmpty) &&
          (pinfl == null || pinfl.isEmpty);

      // 3. Foydalanuvchi identifikatsiyasi (MyID SDK)
      onStatusUpdate?.call('MyID SDK ishga tushirilmoqda...');
      final identifyResult = await identifyUser(
        sessionId: sessionId,
        forcePassportScreen: isEmptySession,
      );

      if (identifyResult['success'] != true) {
        return {
          'success': false,
          'error': 'Identifikatsiya xatosi',
          'details': identifyResult,
        };
      }

      // 4. Foydalanuvchi ma'lumotlarini olish
      onStatusUpdate?.call('Foydalanuvchi ma\'lumotlari olinmoqda...');
      final profileResult = await getUserProfile(
        accessToken: accessToken,
        sessionId: sessionId,
      );

      if (profileResult['success'] != true) {
        return {
          'success': false,
          'error': 'Profil ma\'lumotlarini olishda xatolik',
          'details': profileResult,
        };
      }

      // 5. Muvaffaqiyatli natija
      return {
        'success': true,
        'access_token': accessToken,
        'session_id': sessionId,
        'profile': profileResult['profile'],
        'data': profileResult['data'],
        'comparison_value': profileResult['comparison_value'],
        'pers_data': profileResult['pers_data'],
        'pin_id': profileResult['pin_id'],
        'message': 'Muvaffaqiyatli autentifikatsiya!',
      };
    } catch (e) {
      return {'success': false, 'error': 'Kutilmagan xatolik: ${e.toString()}'};
    }
  }

  /// 5. Sessiyani tiklash (Restore Session)
  /// Rasmda: "Vosstanovleniye sessii" - GET /sdk/sessions/{session_id}
  /// Agar SDK 10 daqiqadan ko'proq vaqt o'tgandan keyin qayta ishga tushirilsa,
  /// sessiya statusini olish mumkin
  static Future<Map<String, dynamic>> restoreSession({
    required String accessToken,
    required String sessionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/sdk/sessions/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'code': data['code'],
          'status': data['status'],
          'attempts': data['attempts'],
          'job_id': data['job_id'],
          'timestamp': data['timestamp'],
          'reason': data['reason'],
          'reason_code': data['reason_code'],
        };
      } else if (response.statusCode >= 400) {
        return {'success': false, 'error': 'Error message', 'detail': 'err'};
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
