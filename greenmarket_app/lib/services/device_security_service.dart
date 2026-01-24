import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Qurilma xavfsizlik tekshiruvi servisi
///
/// MyID SDK root va emulyator tekshiruvlarini o'z ichiga olmaydi.
/// Shuning uchun ota-ilovada bu tekshiruvlarni amalga oshirish kerak.
class DeviceSecurityService {
  static const platform = MethodChannel('com.greenmarket.app/security');

  /// Qurilma root'langan yoki yo'qligini tekshirish
  ///
  /// Returns:
  /// - true: Qurilma root'langan
  /// - false: Qurilma xavfsiz
  static Future<bool> isDeviceRooted() async {
    try {
      final bool result = await platform.invokeMethod('isDeviceRooted');
      debugPrint(
        '🔍 Root tekshiruvi: ${result ? "ROOT TOPILDI ⚠️" : "Xavfsiz ✅"}',
      );
      return result;
    } catch (e) {
      debugPrint('❌ Root tekshiruvda xato: $e');
      return false;
    }
  }

  /// Emulyatorni tekshirish
  ///
  /// Returns:
  /// - true: Emulyator
  /// - false: Haqiqiy qurilma
  static Future<bool> isEmulator() async {
    try {
      final bool result = await platform.invokeMethod('isEmulator');
      debugPrint(
        '🔍 Emulyator tekshiruvi: ${result ? "EMULYATOR TOPILDI ⚠️" : "Haqiqiy qurilma ✅"}',
      );
      return result;
    } catch (e) {
      debugPrint('❌ Emulyator tekshiruvda xato: $e');
      return false;
    }
  }

  /// Qurilmaning xavfsizlik holatini tekshirish
  ///
  /// Returns:
  /// - true: Qurilma xavfsiz (root yo'q, emulyator yo'q)
  /// - false: Qurilma xavfsiz emas
  static Future<bool> isDeviceSecure() async {
    try {
      final isRooted = await isDeviceRooted();
      final isEmu = await isEmulator();

      final isSecure = !isRooted && !isEmu;

      if (isSecure) {
        debugPrint('✅ Qurilma xavfsiz - MyID SDK ishga tushirilishi mumkin');
      } else {
        if (isRooted) {
          debugPrint('⚠️ XAVFSIZLIK MUAMMOSI: Qurilma root\'langan!');
        }
        if (isEmu) {
          debugPrint('⚠️ XAVFSIZLIK MUAMMOSI: Emulyator aniqlandi!');
        }
      }

      return isSecure;
    } catch (e) {
      debugPrint('❌ Xavfsizlik tekshiruvda xato: $e');
      return false;
    }
  }

  /// Qurilmaning xavfsizlik holatini batafsil tekshirish
  ///
  /// Returns:
  /// - `rooted`: Qurilma root'langan
  /// - `emulator`: Emulyator aniqlandi
  /// - `secure`: Qurilma xavfsiz
  /// - `message`: Tafsilotli xabar
  static Future<Map<String, dynamic>> getSecurityStatus() async {
    try {
      final isRooted = await isDeviceRooted();
      final isEmu = await isEmulator();
      final isSecure = !isRooted && !isEmu;

      String message = '';
      if (isSecure) {
        message = 'Qurilma xavfsiz - MyID SDK ishga tushirilishi mumkin ✅';
      } else {
        final issues = <String>[];
        if (isRooted) issues.add('Root aniqlandi');
        if (isEmu) issues.add('Emulyator aniqlandi');
        message = 'Xavfsizlik muammolari: ${issues.join(", ")} ⚠️';
      }

      return {
        'rooted': isRooted,
        'emulator': isEmu,
        'secure': isSecure,
        'message': message,
      };
    } catch (e) {
      return {
        'rooted': false,
        'emulator': false,
        'secure': false,
        'message': 'Xavfsizlik tekshiruvda xato: $e',
      };
    }
  }
}
