import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'myid_code_verification_service.dart';

/// MyID Native SDK Service - Kotlin orqali SDK'ni chaqiradi
class MyIdNativeService {
  static const platform = MethodChannel('com.greenmarket/myid');

  /// MyID SDK'ni ishga tushirish
  static Future<Map<String, dynamic>> startMyIdSDK({
    required String clientHash,
    required String clientHashId,
    required String passportSeries,
    required String passportNumber,
    required String birthDate,
    required String sessionId,
  }) async {
    try {
      debugPrint('🔵 NATIVE SDK: Kotlin orqali SDK ishga tushirilmoqda...');
      debugPrint('   Client Hash: ${clientHash.substring(0, 20)}...');
      debugPrint('   Passport: $passportSeries/$passportNumber');
      debugPrint('   Session ID: $sessionId');

      final Map<dynamic, dynamic> result = await platform
          .invokeMethod('startMyIdSDK', {
            'clientHash': clientHash,
            'clientHashId': clientHashId,
            'passportSeries': passportSeries,
            'passportNumber': passportNumber,
            'birthDate': birthDate,
          });

      debugPrint('✅ NATIVE SDK: Natija olindi');
      debugPrint('   Code: ${result['code']?.toString().substring(0, 20)}...');

      // SDK'dan kelgan kodni backend'ga yuborish
      if (result['success'] == true && result['code'] != null) {
        debugPrint('🔵 NATIVE SDK: Kodni backend\'ga yuborilmoqda...');

        final verifyResult = await MyIdCodeVerificationService.verifyCode(
          code: result['code'],
          sessionId: sessionId,
        );

        return verifyResult;
      }

      return {
        'success': result['success'] ?? false,
        'code': result['code'],
        'base64_image': result['base64_image'],
      };
    } on PlatformException catch (e) {
      debugPrint('❌ NATIVE SDK XATOSI: ${e.code}');
      debugPrint('   Message: ${e.message}');

      return {
        'success': false,
        'error': e.message ?? 'MyID SDK xatosi',
        'code': e.code,
      };
    } catch (e) {
      debugPrint('❌ NATIVE SDK KUTILMAGAN XATOSI: $e');
      return {'success': false, 'error': 'Kutilmagan xato: $e'};
    }
  }
}
