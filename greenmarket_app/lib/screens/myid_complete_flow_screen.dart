import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/myid_config.dart' as app_config;

/// MyID To'liq Oqim - Rasmda ko'rsatilgan oqim
///
/// Bu ekran rasmda ko'rsatilgan to'liq oqimni amalga oshiradi:
/// 1. Backend orqali access token olish
/// 2. Bo'sh session yaratish
/// 3. SDK ni session_id bilan ishga tushirish
/// 4. SDK'dan code va rasmlarni olish
/// 5. Backend'ga yuborish
/// 6. Profil ma'lumotlarini olish
/// 7. Ma'lumotlar bazasiga saqlash
class MyIdCompleteFlowScreen extends StatefulWidget {
  const MyIdCompleteFlowScreen({super.key});

  @override
  State<MyIdCompleteFlowScreen> createState() => _MyIdCompleteFlowScreenState();
}

class _MyIdCompleteFlowScreenState extends State<MyIdCompleteFlowScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  int _currentStep = 0;
  String _sessionId = '';

  static const String _backendUrl =
      'https://greenmarket-backend-lilac.vercel.app';

  /// To'liq oqim - rasmga muvofiq
  Future<void> _startCompleteFlow() async {
    setState(() {
      _isLoading = true;
      _currentStep = 1;
      _statusMessage = 'Oqim boshlanimoqda...';
    });

    try {
      // ============================================
      // 1-QADAM: Backend orqali bo'sh session yaratish
      // ============================================
      if (kDebugMode) {
        debugPrint('🔵 [1/7] Backend orqali bo\'sh session yaratilmoqda...');
      }

      setState(() {
        _currentStep = 1;
        _statusMessage = 'Backend orqali session yaratilmoqda...';
      });

      final sessionResponse = await http.post(
        Uri.parse('$_backendUrl/api/myid/create-session'),
        headers: {'Content-Type': 'application/json'},
      );

      if (sessionResponse.statusCode != 200) {
        throw Exception('Session yaratishda xato: ${sessionResponse.body}');
      }

      final sessionData = json.decode(sessionResponse.body);
      _sessionId =
          sessionData['session_id'] ?? sessionData['data']['session_id'];

      if (kDebugMode) {
        debugPrint('✅ [1/7] Session yaratildi: $_sessionId');
      }

      // ============================================
      // 2-QADAM: SDK ni session_id bilan ishga tushirish
      // ============================================
      if (kDebugMode) {
        debugPrint('🔵 [2/7] SDK ishga tushirilmoqda...');
      }

      setState(() {
        _currentStep = 2;
        _statusMessage = 'MyID SDK ishga tushirilmoqda...';
      });

      final config = MyIdConfig(
        sessionId: _sessionId,
        clientHash: app_config.MyIDConfig.clientHash,
        clientHashId: app_config.MyIDConfig.clientHashId,
        environment: MyIdEnvironment.DEBUG,
        entryType: MyIdEntryType.IDENTIFICATION,
        locale: MyIdLocale.UZBEK,
      );

      final result = await MyIdClient.start(
        config: config,
        iosAppearance: const MyIdIOSAppearance(),
      );

      if (kDebugMode) {
        debugPrint('✅ [2/7] SDK natija:');
        debugPrint('   - code: ${result.code}');
        debugPrint('   - base64: ${result.base64?.length ?? 0} bytes');
      }

      if (result.code == null || result.code!.isEmpty) {
        throw Exception('SDK code null yoki bo\'sh');
      }

      // ============================================
      // 3-QADAM: Backend'ga code va rasmlarni yuborish
      // ============================================
      if (kDebugMode) {
        debugPrint('🔵 [3/7] Backend\'ga code va rasmlar yuborilmoqda...');
      }

      setState(() {
        _currentStep = 3;
        _statusMessage = 'Backend\'ga ma\'lumotlar yuborilmoqda...';
      });

      final userInfoResponse = await http.post(
        Uri.parse('$_backendUrl/api/myid/get-user-info-with-images'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'code': result.code,
          'base64_image': result.base64,
          'session_id': _sessionId,
        }),
      );

      if (userInfoResponse.statusCode != 200) {
        throw Exception('Profil olishda xato: ${userInfoResponse.body}');
      }

      final userInfo = json.decode(userInfoResponse.body);

      if (kDebugMode) {
        debugPrint('✅ [3/7] Backend\'dan javob olindi');
        debugPrint('   - User ID: ${userInfo['user']?['id']}');
        debugPrint('   - PINFL: ${userInfo['user']?['pinfl']}');
      }

      // ============================================
      // 4-QADAM: Profil ma'lumotlarini olish
      // ============================================
      if (kDebugMode) {
        debugPrint('🔵 [4/7] Profil ma\'lumotlari olinmoqda...');
      }

      setState(() {
        _currentStep = 4;
        _statusMessage = 'Profil ma\'lumotlari olinmoqda...';
      });

      final profile = userInfo['profile'] ?? {};

      if (kDebugMode) {
        debugPrint('✅ [4/7] Profil ma\'lumotlari:');
        debugPrint('   - Ism: ${profile['first_name']}');
        debugPrint('   - Familya: ${profile['last_name']}');
        debugPrint('   - Tug\'ilgan sana: ${profile['birth_date']}');
      }

      // ============================================
      // 5-QADAM: Rasmlarni tekshirish
      // ============================================
      if (kDebugMode) {
        debugPrint('🔵 [5/7] Rasmlar tekshirilmoqda...');
      }

      setState(() {
        _currentStep = 5;
        _statusMessage = 'Rasmlar tekshirilmoqda...';
      });

      final hasFaceImage = result.base64 != null && result.base64!.isNotEmpty;

      if (kDebugMode) {
        debugPrint('✅ [5/7] Rasmlar:');
        debugPrint('   - Yuz rasmi: ${hasFaceImage ? 'bor' : 'yo\'q'}');
        debugPrint(
          '   - Pasport rasmi: ${result.base64 != null ? 'bor' : 'yo\'q'}',
        );
      }

      // ============================================
      // 6-QADAM: Ma'lumotlarni saqlash
      // ============================================
      if (kDebugMode) {
        debugPrint('🔵 [6/7] Ma\'lumotlar saqlanmoqda...');
      }

      setState(() {
        _currentStep = 6;
        _statusMessage = 'Ma\'lumotlar saqlanmoqda...';
      });

      final userData = {
        'pinfl': result.code,
        'session_id': _sessionId,
        'profile': profile,
        'verified': true,
        'timestamp': DateTime.now().toIso8601String(),
        'auth_method': 'complete_flow',
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(userData));

      if (kDebugMode) {
        debugPrint('✅ [6/7] Ma\'lumotlar saqlandi');
      }

      // ============================================
      // 7-QADAM: Yakunlash
      // ============================================
      if (kDebugMode) {
        debugPrint('🔵 [7/7] Yakunlanmoqda...');
      }

      setState(() {
        _currentStep = 7;
        _statusMessage = 'Muvaffaqiyatli yakunlandi!';
      });

      if (kDebugMode) {
        debugPrint('✅ [7/7] To\'liq oqim muvaffaqiyatli yakunlandi!');
      }

      // Home ekraniga o'tish
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 Xato: $e');
      }

      setState(() {
        _statusMessage = 'Xato: ${e.toString()}';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xato: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'MyID To\'liq Oqim',
          style: TextStyle(
            color: Color(0xFF1A2E1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: _isLoading
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2E1A)),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading ? _buildProgressView() : _buildStartView(),
        ),
      ),
    );
  }

  /// Boshlash ko'rinishi
  Widget _buildStartView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo
        Center(
          child: Container(
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
        ),
        const SizedBox(height: 32),

        // Sarlavha
        const Text(
          'To\'liq Oqim',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2E1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rasmda ko\'rsatilgan to\'liq oqim',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),

        // Oqim bosqichlari
        _buildFlowStep(1, 'Backend orqali session yaratish'),
        _buildFlowStep(2, 'SDK ni ishga tushirish'),
        _buildFlowStep(3, 'Code va rasmlarni olish'),
        _buildFlowStep(4, 'Profil ma\'lumotlarini olish'),
        _buildFlowStep(5, 'Rasmlarni tekshirish'),
        _buildFlowStep(6, 'Ma\'lumotlarni saqlash'),
        _buildFlowStep(7, 'Yakunlash'),

        const SizedBox(height: 32),

        // Boshlash tugmasi
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startCompleteFlow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066cc),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Oqimni boshlash',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  /// Oqim bosqichi
  Widget _buildFlowStep(int step, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0066cc),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A2E1A)),
            ),
          ),
        ],
      ),
    );
  }

  /// Jarayon ko'rinishi
  Widget _buildProgressView() {
    return Column(
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

        // Bosqich
        Text(
          'Bosqich $_currentStep/7',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2E1A),
          ),
        ),
        const SizedBox(height: 12),

        // Holat xabari
        Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),

        // Progress bar
        SizedBox(
          width: double.infinity,
          child: LinearProgressIndicator(
            value: _currentStep / 7,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0066cc)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 32),

        // Loading indikator
        const CircularProgressIndicator(color: Color(0xFF0066cc)),
      ],
    );
  }
}
