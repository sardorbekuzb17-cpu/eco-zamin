import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import '../config/myid_config.dart' as app_config;

/// MyID OAuth to'liq integratsiya servisi
/// Foydalanuvchi taqdim etgan Sequence Diagram'ga muvofiq ishlaydi
class MyIdOAuthService {
  // Backend URL
  static const String _backendUrl = 'https://myid-backend.vercel.app';

  // MyID credentials - Client Hash
  static const String _clientHash = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5wQYaS8i1b0Rj5wuJLhI
yDuTW/WoWB/kRbJCBHFLyFTxETADNa/CU+xw0moN9X10+MVD5kRMinMRQpGUVCrU
XjUAEjwbdaCSLR6suRYI1EfDMQ5XFdJsfkAlNzZyyfBlif4OA4qxaMtdyvJCa/8n
wHn2KC89BNhqBQMre7iLaW8Z9bArSulSxBJzbzPjd7Jkg4ccQ47bVyjEKBcu/1KX
Ud/audUr1WsUpBf9yvgSTDRG2cuVXpMGEBJAqrsCS3RtIt7pEnGtr5FsB+UmBec9
Ei97fK2LcVfWpc/m7WjWMz3mku/pmhSjC6Vl6dlOrP1dv/fJkhfh3axzXtZoxgV1
QwIDAQAB
-----END PUBLIC KEY-----''';

  /// 1. Create Session (Sequence Diagram Step 1-6)
  /// Mobile APP -> Client Backend -> MyID Backend -> return session_id
  static Future<Map<String, dynamic>> createSession({
    String? phoneNumber,
    String? birthDate,
    bool? isResident,
    String? passData,
    String? pinfl,
    double? threshold,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {};

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

      // Backend endpoint: /api/myid/create-session
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/myid/create-session'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sessionId = data['session_id'] ?? data['data']?['session_id'];

        if (sessionId != null) {
          return {'success': true, 'session_id': sessionId};
        }
        return {
          'success': false,
          'error': 'Session ID topilmadi',
          'details': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Backend xatosi (Session): ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'error': 'Sessiya yaratishda timeout (45s). Iltimos qayta urining.',
        };
      }
      return {'success': false, 'error': 'Sessiya xatosi: $e'};
    }
  }

  /// 2. Identify User (Sequence Diagram Step 7-10)
  /// Mobile APP -> MyIDSDK -> MyID Backend -> return code & image
  static Future<Map<String, dynamic>> identifyUser({
    required String sessionId,
    bool forcePassportScreen = false,
  }) async {
    try {
      final env = kReleaseMode
          ? MyIdEnvironment.PRODUCTION
          : MyIdEnvironment.DEBUG;

      final result = await MyIdClient.start(
        config: MyIdConfig(
          sessionId: sessionId,
          clientHash: _clientHash,
          clientHashId: app_config.MyIDConfig.clientHashId,
          environment: env,
          entryType: MyIdEntryType.IDENTIFICATION,
          locale: MyIdLocale.UZBEK,
          residency: forcePassportScreen
              ? MyIdResidency.USER_DEFINED
              : MyIdResidency.RESIDENT,
          // Huawei qurilmalari uchun (agar kerak bo'lsa)
          huaweiAppId: '', // Huawei App ID'ni shu yerga qo'ying
        ),
        iosAppearance: const MyIdIOSAppearance(),
      );

      // result.code '0' bo'lsa muvaffaqiyatli (yoki null emasligi)
      // Diagramma bo'yicha bizga code va image kerak
      if (result.code != null && result.code!.isNotEmpty) {
        return {
          'success': true,
          'code': result.code,
          'base64_image': result.base64,
          'result': result,
        };
      } else {
        return {'success': false, 'error': 'MyID SDK: Code qaytarilmadi'};
      }
    } catch (e) {
      return {'success': false, 'error': 'SDK xatosi: $e'};
    }
  }

  /// 3. Send to Backend & Retrieve User Data (Sequence Diagram Step 11-14)
  /// Mobile APP -> Client Backend -> MyID Backend -> return profile, reuid, comparison_value
  static Future<Map<String, dynamic>> getUserProfile({
    required String sessionId,
    String? code,
    String? base64Image,
  }) async {
    try {
      // Sequence diagram bo'yicha: session_id, image (base64_image), code yuboriladi
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/myid/get-user-info-with-images'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'session_id': sessionId,
              'code': code,
              'base64_image': base64Image,
            }),
          )
          .timeout(
            const Duration(seconds: 60),
          ); // Timeoutni 60 soniyaga oshiramiz

      if (response.statusCode == 200) {
        final respData = json.decode(response.body);
        if (respData['success'] == true) {
          final data = respData['data'] ?? respData;
          return {
            'success': true,
            'profile': data['profile'] ?? {},
            'reuid': data['reuid'],
            'comparison_value': data['comparison_value'],
            'data': data,
          };
        }
        return {
          'success': false,
          'error': respData['error'] ?? 'Ma\'lumot olishda xatolik',
        };
      } else {
        return {
          'success': false,
          'error': 'Backend error: ${response.statusCode}',
        };
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'error': 'Profil olishda timeout (60s). Iltimos qayta urining.',
        };
      }
      return {'success': false, 'error': 'Profil xatosi: $e'};
    }
  }

  /// TO'LIQ OQIM (End-to-End)
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
      // 1. Step 1-6: Session
      onStatusUpdate?.call('Sessiya yaratilmoqda...');
      final sessionResult = await createSession(
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        isResident: isResident,
        passData: passData,
        pinfl: pinfl,
        threshold: threshold,
      );

      if (sessionResult['success'] != true) return sessionResult;
      final sessionId = sessionResult['session_id'];

      // 2. Step 7-10: SDK Identification
      onStatusUpdate?.call('MyID SDK ishga tushirilmoqda...');
      final isEmptySession =
          (phoneNumber == null || phoneNumber.isEmpty) &&
          (birthDate == null || birthDate.isEmpty) &&
          (passData == null || passData.isEmpty);

      final identifyResult = await identifyUser(
        sessionId: sessionId,
        forcePassportScreen: isEmptySession,
      );

      if (identifyResult['success'] != true) {
        return {
          'success': false,
          'error': 'Identifikatsiya bekor qilindi yoki xato.',
        };
      }

      // 3. Step 11-14: Send to backend
      onStatusUpdate?.call('Ma\'lumotlar backend\'ga yuborilmoqda...');
      final profileResult = await getUserProfile(
        sessionId: sessionId,
        code: identifyResult['code'],
        base64Image: identifyResult['base64_image'],
      );

      return profileResult;
    } catch (e) {
      return {'success': false, 'error': 'Kutilmagan xato: $e'};
    }
  }
}
