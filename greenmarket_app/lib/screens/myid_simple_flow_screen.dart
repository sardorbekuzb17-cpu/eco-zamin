import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

/// MyID Simple Flow - API'siz
///
/// Bu ekran MyID SDK'ni to'g'ridan-to'g'ri ishlatadi, backend kerak emas.
/// Foydalanuvchi pasport ma'lumotlarini kiritadi va SDK tekshiradi.
class MyIdSimpleFlowScreen extends StatefulWidget {
  const MyIdSimpleFlowScreen({super.key});

  @override
  State<MyIdSimpleFlowScreen> createState() => _MyIdSimpleFlowScreenState();
}

class _MyIdSimpleFlowScreenState extends State<MyIdSimpleFlowScreen> {
  bool _isLoading = false;
  String _statusMessage = 'MyID SDK ishga tushirilmoqda...';

  @override
  void initState() {
    super.initState();
    _startMyIdSdk();
  }

  /// MyID SDK'ni to'g'ridan-to'g'ri ishga tushirish
  Future<void> _startMyIdSdk() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'MyID SDK ishga tushirilmoqda...';
    });

    try {
      if (kDebugMode) {
        debugPrint('🔵 MyID SDK ishga tushirilmoqda (Simple Flow)...');
      }

      // UUID bilan session yaratish
      const uuid = Uuid();
      final sessionId = uuid.v4();

      if (kDebugMode) {
        debugPrint('   Session ID: $sessionId');
      }

      // Saqlangan tilni yuklash
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('language') ?? 'uz';

      // Tilga mos MyIdLocale tanlash
      MyIdLocale locale;
      switch (savedLanguage) {
        case 'ru':
          locale = MyIdLocale.RUSSIAN;
          break;
        case 'en':
          locale = MyIdLocale.ENGLISH;
          break;
        default:
          locale = MyIdLocale.UZBEK;
      }

      // MyID SDK'ni ishga tushirish
      final result = await MyIdClient.start(
        config: MyIdConfig(
          sessionId: sessionId,
          clientHash: '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5wQYaS8i1b0Rj5wuJLhI
yDuTW/WoWB/kRbJCBHFLyFTxETADNa/CU+xw0moN9X10+MVD5kRMinMRQpGUVCrU
XjUAEjwbdaCSLR6suRYI1EfDMQ5XFdJsfkAlNzZyyfBlif4OA4qxaMtdyvJCa/8n
wHn2KC89BNhqBQMre7iLaW8Z9bArSulSxBJzbzPjd7Jkg4ccQ47bVyjEKBcu/1KX
Ud/audUr1WsUpBf9yvgSTDRG2cuVXpMGEBJAqrsCS3RtIt7pEnGtr5FsB+UmBec9
Ei97fK2LcVfWpc/m7WjWMz3mku/pmhSjC6Vl6dlOrP1dv/fJkhfh3axzXtZoxgV1
QwIDAQAB
-----END PUBLIC KEY-----''',
          clientHashId: 'ac6d0f4a-5d5b-44e3-a865-9159a3146a8c',
          environment: MyIdEnvironment.DEBUG,
          entryType: MyIdEntryType.IDENTIFICATION,
          residency: MyIdResidency.USER_DEFINED,
          locale: locale,
        ),
        iosAppearance: const MyIdIOSAppearance(),
      );

      if (kDebugMode) {
        debugPrint('✅ MyID SDK natija olindi');
        debugPrint('   Code (PINFL): ${result.code}');
      }

      // Natijani qayta ishlash
      await _handleMyIdResult(result);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 MyID SDK xatosi: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  /// MyID natijasini qayta ishlash
  Future<void> _handleMyIdResult(MyIdResult result) async {
    try {
      if (kDebugMode) {
        debugPrint('🔵 MyID natijasini qayta ishlash');
        debugPrint('   result.code: ${result.code}');
      }

      // Xato - code null yoki bo'sh
      if (result.code == null || result.code!.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ Foydalanuvchi jarayonni bekor qildi');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jarayon bekor qilindi'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context);
        }
        return;
      }

      if (kDebugMode) {
        debugPrint('✅ Muvaffaqiyatli - PINFL olindi: ${result.code}');
      }

      // Muvaffaqiyatli natija - PINFL olindi
      final userData = {
        'pinfl': result.code!,
        'full_name': 'MyID User',
        'verified': true,
        'timestamp': DateTime.now().toIso8601String(),
        'myid_code': result.code,
        'has_photo': result.base64 != null,
      };

      // SharedPreferences'ga saqlash
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(userData));

      if (kDebugMode) {
        debugPrint('✅ Foydalanuvchi ma\'lumotlari saqlandi');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Muvaffaqiyatli kirish!'),
            backgroundColor: Colors.green,
          ),
        );

        // Home ekraniga o'tish
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 Ma\'lumotlarni saqlashda xato: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'MyID Kirish',
          style: TextStyle(
            color: Color(0xFF1A2E1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // MyID logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF0066cc).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066cc),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'ID',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Holat xabari
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Loading indikator
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFF0066cc)),
            ],
          ),
        ),
      ),
    );
  }
}
