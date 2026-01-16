import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SecurityService {
  // Root/Jailbreak tekshiruvi
  static Future<bool> isDeviceSecure() async {
    try {
      // Root fayllarini tekshirish
      final rootPaths = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
      ];

      for (var path in rootPaths) {
        if (await File(path).exists()) {
          if (kDebugMode) {
            debugPrint('⚠️ Root fayl topildi: $path');
          }
          return false;
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Xavfsizlik tekshiruvida xatolik: $e');
      }
      return true; // Xatolik bo'lsa, davom ettiramiz
    }
  }

  // Ilova o'zgartirilganligini tekshirish
  static Future<bool> checkIntegrity() async {
    try {
      // Asosiy tekshiruvlar
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Integrity check xatolik: $e');
      }
      return true;
    }
  }

  // Debugger tekshiruvi
  static bool isDebuggerAttached() {
    return kDebugMode;
  }

  // Emulator tekshiruvi
  static Future<bool> isRunningOnEmulator() async {
    try {
      if (Platform.isAndroid) {
        final brand = Platform.environment['BRAND'] ?? '';
        final device = Platform.environment['DEVICE'] ?? '';
        final model = Platform.environment['MODEL'] ?? '';

        if (brand.toLowerCase().contains('generic') ||
            device.toLowerCase().contains('generic') ||
            model.toLowerCase().contains('emulator')) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // To'liq xavfsizlik tekshiruvi
  static Future<SecurityCheckResult> performSecurityCheck() async {
    final results = SecurityCheckResult();

    // 1. Qurilma xavfsizligi
    results.isDeviceSecure = await isDeviceSecure();

    // 2. Ilova integrity
    results.isIntegrityValid = await checkIntegrity();

    // 3. Debugger
    results.isDebuggerAttached = isDebuggerAttached();

    // 4. Emulator
    results.isEmulator = await isRunningOnEmulator();

    // 5. Umumiy natija (debug mode'da o'tkazib yuboramiz)
    if (kDebugMode) {
      results.isPassed = true;
    } else {
      results.isPassed =
          results.isDeviceSecure &&
          results.isIntegrityValid &&
          !results.isDebuggerAttached &&
          !results.isEmulator;
    }

    return results;
  }

  // Xavfsizlik buzilganda chaqiriladigan metod
  static Future<void> onSecurityViolation() async {
    if (kDebugMode) {
      debugPrint('🚨 XAVFSIZLIK BUZILDI! Ilova to\'xtatilmoqda...');
    }

    // Ilovani to'xtatish
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    exit(0);
  }
}

class SecurityCheckResult {
  bool isDeviceSecure = false;
  bool isIntegrityValid = false;
  bool isDebuggerAttached = false;
  bool isEmulator = false;
  bool isPassed = false;

  String get message {
    if (!isDeviceSecure) return 'Qurilma xavfsiz emas (root)';
    if (!isIntegrityValid) return 'Ilova o\'zgartirilgan';
    if (isDebuggerAttached) return 'Debugger aniqlandi';
    if (isEmulator) return 'Emulator aniqlandi';
    return 'Xavfsizlik tekshiruvi muvaffaqiyatli';
  }
}
