import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:safe_device/safe_device.dart'; // Vaqtincha o'chirildi

class SecurityService {
  // Root/Jailbreak tekshiruvi (vaqtincha o'chirilgan)
  static Future<bool> isDeviceSecure() async {
    try {
      // safe_device kutubxonasi o'chirilgan - debug mode'da true qaytaramiz
      if (kDebugMode) {
        debugPrint('⚠️ Xavfsizlik tekshiruvi o\'chirilgan (debug mode)');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Xavfsizlik tekshiruvida xatolik: $e');
      }
      return kDebugMode;
    }
  }

  // Haqiqiy qurilma tekshiruvi (vaqtincha o'chirilgan)
  static Future<bool> isRealDevice() async {
    try {
      // safe_device kutubxonasi o'chirilgan - debug mode'da true qaytaramiz
      if (kDebugMode) {
        debugPrint('⚠️ Emulator tekshiruvi o\'chirilgan (debug mode)');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Emulator tekshiruvida xatolik: $e');
      }
      return kDebugMode;
    }
  }

  // MyID SDK ishga tushishdan oldin xavfsizlik tekshiruvi
  static Future<void> checkSecurityBeforeMyId(BuildContext context) async {
    // Debug mode'da tekshiruvlarni o'tkazib yuboramiz
    if (kDebugMode) {
      debugPrint('🔓 Debug mode: Xavfsizlik tekshiruvlari o\'tkazib yuborildi');
      return;
    }

    // 1. Root/Jailbreak tekshiruvi
    final isSecure = await isDeviceSecure();
    if (!isSecure) {
      if (context.mounted) {
        await _showSecurityDialog(
          context,
          'Xavfsizlik Ogohlantirishi',
          'Qurilmangiz root/jailbreak qilingan. MyID xavfsizlik sabablariga ko\'ra ishlamaydi.\n\nIltimos, standart qurilmada sinab ko\'ring.',
        );
      }
      throw Exception('Device is rooted/jailbroken');
    }

    // 2. Emulator tekshiruvi
    final isReal = await isRealDevice();
    if (!isReal) {
      if (context.mounted) {
        await _showSecurityDialog(
          context,
          'Emulator Aniqlandi',
          'MyID emulator yoki simulator\'da ishlamaydi.\n\nIltimos, haqiqiy qurilmada sinab ko\'ring.',
        );
      }
      throw Exception('Running on emulator/simulator');
    }
  }

  // Xavfsizlik dialog'ini ko'rsatish
  static Future<void> _showSecurityDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.red[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Ilova o'zgartirilganligini tekshirish (vaqtincha o'chirilgan)
  static Future<bool> checkIntegrity() async {
    try {
      // safe_device kutubxonasi o'chirilgan - debug mode'da true qaytaramiz
      if (kDebugMode) {
        debugPrint('⚠️ Integrity check o\'chirilgan (debug mode)');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Integrity check xatolik: $e');
      }
      return kDebugMode;
    }
  }

  // Debugger tekshiruvi
  static bool isDebuggerAttached() {
    return kDebugMode;
  }

  // Emulator tekshiruvi (eski metod - yangi isRealDevice() ishlatiladi)
  @Deprecated('isRealDevice() metodini ishlating')
  static Future<bool> isRunningOnEmulator() async {
    return !(await isRealDevice());
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
    results.isEmulator = !(await isRealDevice());

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
