import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/myid_backend_service.dart';

class MyIdSdkLoginScreen extends StatefulWidget {
  const MyIdSdkLoginScreen({super.key});

  @override
  State<MyIdSdkLoginScreen> createState() => _MyIdSdkLoginScreenState();
}

class _MyIdSdkLoginScreenState extends State<MyIdSdkLoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _createSession();
  }

  // 1. Backend'dan session yaratish
  Future<void> _createSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Xavfsizlik tekshiruvi vaqtincha o'chirilgan - test uchun
      // await SecurityService.checkSecurityBeforeMyId(context);

      final result = await MyIdBackendService.createEmptySession();

      if (result['success'] == true) {
        final sessionId = result['data']['session_id'] as String?;

        if (sessionId != null) {
          setState(() {
            _sessionId = sessionId;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Session ID topilmadi';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Session yaratishda xato';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Xatolik: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // 2. MyID SDK'ni ishga tushirish
  Future<void> _startMyIdSdk() async {
    if (_sessionId == null) {
      setState(() {
        _errorMessage = 'Session ID mavjud emas';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kDebugMode) {
        debugPrint('🔵 MyID SDK ishga tushirilmoqda...');
        debugPrint('   Session ID: $_sessionId');
      }

      // MyID SDK'ni ishga tushirish
      final result = await MyIdClient.start(
        config: MyIdConfig(
          sessionId: _sessionId!,
          clientHash:
              '''MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5wQYaS8i1b0Rj5wuJLhIyDuTW/WoWB/kRbJCBHFLyFTxETADNa/CU+xw0moN9X10+MVD5kRMinMRQpGUVCrUXjUAEjwbdaCSLR6suRYI1EfDMQ5XFdJsfkAlNzZyyfBlif4OA4qxaMtdyvJCa/8nwHn2KC89BNhqBQMre7iLaW8Z9bArSulSxBJzbzPjd7Jkg4ccQ47bVyjEKBcu/1KXUd/audUr1WsUpBf9yvgSTDRG2cuVXpMGEBJAqrsCS3RtIt7pEnGtr5FsB+UmBec9Ei97fK2LcVfWpc/m7WjWMz3mku/pmhSjC6Vl6dlOrP1dv/fJkhfh3axzXtZoxgV1QwIDAQAB''',
          clientHashId: 'ac6d0f4a-5d5b-44e3-a865-9159a3146a8c',
          environment: MyIdEnvironment.DEBUG, // Test muhiti uchun DEBUG
          entryType: MyIdEntryType.IDENTIFICATION,
          residency: MyIdResidency
              .USER_DEFINED, // Pasport kiritish ekranini ko'rsatish uchun
          locale: MyIdLocale.UZBEK,
        ),
        iosAppearance: const MyIdIOSAppearance(),
      );

      if (kDebugMode) {
        debugPrint('🟢 MyID SDK natija olindi:');
        debugPrint('   Code (PINFL): ${result.code}');
        debugPrint(
          '   Base64 (Photo): ${result.base64 != null ? "Mavjud" : "Yo'q"}',
        );
      }

      // Natijani qayta ishlash
      await _handleMyIdResult(result);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 MyID SDK xatosi: $e');
      }
      setState(() {
        _errorMessage = 'MyID SDK xatosi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // 3. MyID natijasini qayta ishlash
  Future<void> _handleMyIdResult(MyIdResult result) async {
    try {
      if (kDebugMode) {
        debugPrint('🔵 MyID natijasini qayta ishlash...');
        debugPrint('   result.code: ${result.code}');
        debugPrint(
          '   result.base64: ${result.base64 != null ? "Mavjud (${result.base64!.length} bytes)" : "Yo'q"}',
        );
      }

      // MyIdResult faqat code (PINFL) va base64 (rasm) qaytaradi
      // Xato - code null bo'lsa
      if (result.code == null || result.code!.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ MyID natija bo\'sh - foydalanuvchi bekor qilgan bo\'lishi mumkin',
          );
        }
        setState(() {
          _errorMessage = 'MyID natija topilmadi. Qayta urinib ko\'ring.';
          _isLoading = false;
        });
        return;
      }

      if (kDebugMode) {
        debugPrint('✅ PINFL olindi: ${result.code}');
      }

      // Muvaffaqiyatli natija - PINFL (code) olindi
      final userData = {
        'pinfl': result.code!,
        'full_name': 'MyID User', // To'liq ma'lumotlar backend'dan olinadi
        'verified': true,
        'timestamp': DateTime.now().toIso8601String(),
        'myid_code': result.code,
        'has_photo': result.base64 != null,
      };

      // SharedPreferences'ga saqlash
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(userData));

      if (kDebugMode) {
        debugPrint('✅ Foydalanuvchi ma\'lumotlari saqlandi:');
        debugPrint('   PINFL: ${userData['pinfl']}');
        debugPrint('   Photo: ${userData['has_photo']}');
      }

      if (mounted) {
        // Home sahifasiga o'tish
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 Ma\'lumotlarni saqlashda xato: $e');
      }
      setState(() {
        _errorMessage = 'Ma\'lumotlarni saqlashda xato: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2E1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MyID SDK',
          style: TextStyle(
            color: Color(0xFF1A2E1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_sessionId != null) {
      return _buildReadyView();
    }

    return const Center(child: Text('Kutilmagan holat'));
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF15803D)),
          const SizedBox(height: 24),
          Text(
            'Session yaratilmoqda...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Color(0xFF15803D),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Session tayyor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2E1A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'MyID SDK orqali identifikatsiya qilish uchun tayyor',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startMyIdSdk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066cc),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'ID',
                          style: TextStyle(
                            color: Color(0xFF0066cc),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'MyID SDK ni boshlash',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Session 10 daqiqa amal qiladi',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Xatolik yuz berdi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Noma\'lum xato',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _createSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Qayta urinish',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
