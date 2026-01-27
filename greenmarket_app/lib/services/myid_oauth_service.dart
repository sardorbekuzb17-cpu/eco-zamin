import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/myid_config.dart' as app_config;
import 'myid_native_service.dart';

/// MyID OAuth to'liq integratsiya servisi
class MyIdOAuthService {
  // Backend URL
  static const String _backendUrl = 'https://myid-backend.vercel.app';

  /// 1. Create Session - Backend orqali MyID SDK'dan sessiya olish
  static Future<Map<String, dynamic>> createSession({
    String? phoneNumber,
    String? birthDate,
    bool? isResident,
    String? passData,
    String? pinfl,
    double? threshold,
  }) async {
    try {
      debugPrint('🔵 CREATE SESSION: Backend ga sorov yuborilmoqda...');

      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/myid/create-session'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'phone_number': phoneNumber,
              'birth_date': birthDate,
              'is_resident': isResident,
              'pass_data': passData,
              'pinfl': pinfl,
              'threshold': threshold,
            }),
          )
          .timeout(const Duration(seconds: 45));

      debugPrint('🔵 CREATE SESSION: Response status: ${response.statusCode}');
      debugPrint('🔵 CREATE SESSION: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final respData = json.decode(response.body);

        if (respData['success'] == true) {
          final sessionId = respData['session_id'];
          debugPrint('✅ CREATE SESSION: Session yaratildi - $sessionId');

          return {
            'success': true,
            'session_id': sessionId,
            'access_token': respData['access_token'],
            'client_hash': respData['client_hash'],
          };
        }

        debugPrint('❌ CREATE SESSION: Backend xatosi - ${respData['error']}');
        return {
          'success': false,
          'error': respData['error'] ?? 'Session yaratishda xato',
        };
      } else {
        debugPrint('❌ CREATE SESSION: HTTP ${response.statusCode}');
        return {
          'success': false,
          'error': 'Backend error: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('❌ CREATE SESSION XATOSI: $e');
      if (e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'error': 'Sessiya yaratishda timeout (45s). Iltimos qayta urining.',
        };
      }
      return {'success': false, 'error': 'Sessiya xatosi: $e'};
    }
  }

  /// 2. Identify User - Native MyID SDK orqali foydalanuvchini identifikatsiya qilish
  static Future<Map<String, dynamic>> identifyUser({
    required String sessionId,
    required String clientHash,
    required String clientHashId,
    required String passportSeries,
    required String passportNumber,
    required String birthDate,
    bool forcePassportScreen = false,
  }) async {
    try {
      debugPrint('🔵 IDENTIFY USER: Native SDK orqali identifikatsiya...');
      debugPrint('   Session ID: $sessionId');
      debugPrint('   Passport: $passportSeries/$passportNumber');

      // Native SDK'ni chaqirish
      final result = await MyIdNativeService.startMyIdSDK(
        clientHash: clientHash,
        clientHashId: clientHashId,
        passportSeries: passportSeries,
        passportNumber: passportNumber,
        birthDate: birthDate,
        sessionId: sessionId,
      );

      if (result['success'] != true) {
        debugPrint('❌ IDENTIFY USER: SDK xatosi - ${result['error']}');
        return {'success': false, 'error': result['error'] ?? 'SDK xatosi'};
      }

      debugPrint('✅ IDENTIFY USER: Identifikatsiya muvaffaqiyatli');
      debugPrint('   Code: ${result['code']?.toString().substring(0, 20)}...');

      return {
        'success': true,
        'code': result['code'],
        'base64_image': result['base64_image'],
      };
    } catch (e) {
      debugPrint('❌ IDENTIFY USER XATOSI: $e');
      return {'success': false, 'error': 'SDK xatosi: $e'};
    }
  }

  /// 3. Get User Profile - Backend orqali foydalanuvchi malumotlarini olish
  static Future<Map<String, dynamic>> getUserProfile({
    required String sessionId,
    String? code,
    String? base64Image,
  }) async {
    try {
      debugPrint('🔵 GET USER PROFILE: Backend ga sorov yuborilmoqda...');
      debugPrint('   Session ID: $sessionId');
      debugPrint('   Code: ${code?.substring(0, 20)}...');

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
          .timeout(const Duration(seconds: 60));

      debugPrint(
        '🔵 GET USER PROFILE: Response status: ${response.statusCode}',
      );
      debugPrint(
        '🔵 GET USER PROFILE: Response body: ${response.body.substring(0, 200)}...',
      );

      if (response.statusCode == 200) {
        final respData = json.decode(response.body);

        if (respData['success'] == true) {
          final data = respData['data'] ?? respData;
          debugPrint('✅ GET USER PROFILE: Malumotlar olindi');

          return {
            'success': true,
            'session_id': sessionId,
            'profile': data['profile'] ?? {},
            'reuid': data['reuid'],
            'comparison_value': data['comparison_value'],
            'data': data,
          };
        }

        debugPrint('❌ GET USER PROFILE: Backend xatosi - ${respData['error']}');
        return {
          'success': false,
          'error': respData['error'] ?? 'Malumot olishda xatolik',
        };
      } else {
        debugPrint('❌ GET USER PROFILE: HTTP ${response.statusCode}');
        return {
          'success': false,
          'error': 'Backend error: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('❌ GET USER PROFILE XATOSI: $e');
      if (e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'error': 'Profil olishda timeout (60s). Iltimos qayta urining.',
        };
      }
      return {'success': false, 'error': 'Profil xatosi: $e'};
    }
  }

  /// TO'LIQ OQIM (End-to-End) - Barcha qadamlarni ketma-ketlik bilan bajarish
  static Future<Map<String, dynamic>> completeAuthFlow({
    String? phoneNumber,
    String? birthDate,
    bool? isResident,
    String? passData,
    String? pinfl,
    String? passportSeries,
    String? passportNumber,
    double? threshold,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      // 1. Sessiya yaratish
      onStatusUpdate?.call('Sessiya yaratilmoqda...');
      debugPrint('🟢 COMPLETE AUTH FLOW: Boshlandi');

      final sessionResult = await createSession(
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        isResident: isResident,
        passData: passData,
        pinfl: pinfl,
        threshold: threshold,
      );

      if (sessionResult['success'] != true) {
        debugPrint('❌ COMPLETE AUTH FLOW: Session yaratishda xato');
        return sessionResult;
      }

      final sessionId = sessionResult['session_id'];
      final clientHash = sessionResult['client_hash'] ?? '';

      debugPrint('✅ COMPLETE AUTH FLOW: Session yaratildi - $sessionId');
      debugPrint('   Client Hash: ${clientHash.substring(0, 20)}...');

      // 2. MyID SDK orqali identifikatsiya
      onStatusUpdate?.call('MyID SDK ishga tushirilmoqda...');

      final identifyResult = await identifyUser(
        sessionId: sessionId,
        clientHash: clientHash,
        clientHashId: app_config.MyIDConfig.clientHashId,
        passportSeries: passportSeries ?? '',
        passportNumber: passportNumber ?? '',
        birthDate: birthDate ?? '',
      );

      if (identifyResult['success'] != true) {
        debugPrint('❌ COMPLETE AUTH FLOW: Identifikatsiya bekor qilindi');
        return {
          'success': false,
          'error':
              identifyResult['error'] ??
              'Identifikatsiya bekor qilindi yoki xato.',
        };
      }

      debugPrint('✅ COMPLETE AUTH FLOW: Identifikatsiya muvaffaqiyatli');

      // 3. Backend'ga ma'lumotlarni yuborish
      onStatusUpdate?.call('Ma\'lumotlar backend\'ga yuborilmoqda...');
      final profileResult = await getUserProfile(
        sessionId: sessionId,
        code: identifyResult['code'],
        base64Image: identifyResult['base64_image'],
      );

      if (profileResult['success'] == true) {
        debugPrint('✅ COMPLETE AUTH FLOW: Yakunlandi muvaffaqiyatli');
      } else {
        debugPrint('❌ COMPLETE AUTH FLOW: Profil olishda xato');
      }

      return profileResult;
    } catch (e) {
      debugPrint('❌ COMPLETE AUTH FLOW XATOSI: $e');
      return {'success': false, 'error': 'Kutilmagan xato: $e'};
    }
  }
}
