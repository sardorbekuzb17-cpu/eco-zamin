import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/myid_config.dart' as app_config;

/// MyID Bo'sh Session - SDK o'zi pasport so'raydi
///
/// Bu ekran bo'sh session oqimini amalga oshiradi:
/// 1. Backend orqali bo'sh session yaratish
/// 2. SDK ni ishga tushirish (SDK o'zi pasport so'raydi)
/// 3. Code olish va profil ma'lumotlarini olish
class MyIdEmptySessionScreen extends StatefulWidget {
  const MyIdEmptySessionScreen({super.key});

  @override
  State<MyIdEmptySessionScreen> createState() => _MyIdEmptySessionScreenState();
}

class _MyIdEmptySessionScreenState extends State<MyIdEmptySessionScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  int _currentStep = 0;

  static const String _backendUrl =
      'https://greenmarket-backend-lilac.vercel.app';

  /// Bo'sh session oqimi
  Future<void> _startEmptySession() async {
    setState(() {
      _isLoading = true;
      _currentStep = 1;
      _statusMessage = 'Bo\'sh session yaratilmoqda...';
    });

    try {
      // 1. Backend orqali bo'sh session yaratish
      if (kDebugMode) {
        debugPrint('🔵 [1/4] Backend orqali bo\'sh session yaratilmoqda...');
      }

      final sessionResponse = await http.post(
        Uri.parse('$_backendUrl/api/myid/create-session'),
        headers: {'Content-Type': 'application/json'},
      );

      if (sessionResponse.statusCode != 200) {
        throw Exception('Session yaratishda xato: ${sessionResponse.body}');
      }

      final sessionData = json.decode(sessionResponse.body);
      final sessionId = sessionData['session_id'];

      if (kDebugMode) {
        debugPrint('✅ [1/4] Bo\'sh session yaratildi: $sessionId');
      }

      // 2. SDK ni ishga tushirish (SDK o'zi pasport so'raydi)
      setState(() {
        _currentStep = 2;
        _statusMessage = 'MyID SDK ishga tushirilmoqda...';
      });

      if (kDebugMode) {
        debugPrint('🔵 [2/4] SDK ishga tushirilmoqda...');
        debugPrint('   SDK o\'zi pasport ma\'lumotlarini so\'raydi');
      }

      final config = MyIdConfig(
        sessionId: sessionId,
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
        debugPrint('✅ [2/4] SDK natija:');
        debugPrint('   - code: ${result.code}');
        debugPrint('   - base64: ${result.base64?.length ?? 0} bytes');
      }

      if (result.code == null || result.code!.isEmpty) {
        throw Exception('SDK code null yoki bo\'sh');
      }

      // 3. Backend orqali profil ma'lumotlarini olish
      setState(() {
        _currentStep = 3;
        _statusMessage = 'Profil ma\'lumotlari olinmoqda...';
      });

      if (kDebugMode) {
        debugPrint('🔵 [3/4] Backend orqali profil olinmoqda...');
      }

      final userInfoResponse = await http.post(
        Uri.parse('$_backendUrl/api/myid/get-user-info-with-images'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': result.code, 'base64_image': result.base64}),
      );

      if (userInfoResponse.statusCode != 200) {
        throw Exception('Profil olishda xato: ${userInfoResponse.body}');
      }

      final userInfo = json.decode(userInfoResponse.body);

      if (kDebugMode) {
        debugPrint('✅ [3/4] Profil ma\'lumotlari olindi');
      }

      // 4. Ma'lumotlarni saqlash
      setState(() {
        _currentStep = 4;
        _statusMessage = 'Ma\'lumotlar saqlanmoqda...';
      });

      final userData = {
        'pinfl': result.code,
        'profile': userInfo['profile'],
        'verified': true,
        'timestamp': DateTime.now().toIso8601String(),
        'auth_method': 'empty_session',
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(userData));

      if (kDebugMode) {
        debugPrint('✅ [4/4] Muvaffaqiyatli yakunlandi!');
      }

      setState(() {
        _statusMessage = 'Muvaffaqiyatli!';
      });

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
          'MyID Bo\'sh Session',
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
          'Bo\'sh Session',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2E1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'SDK o\'zi pasport ma\'lumotlarini so\'raydi',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),

        // Davom etish tugmasi
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startEmptySession,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066cc),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: const Text(
              'MyID ni boshlash',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Ma'lumot
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bu usulda pasport ma\'lumotlarini oldindan kiritish shart emas. MyID SDK o\'zi sizdan pasport ma\'lumotlarini so\'raydi.',
                  style: TextStyle(color: Colors.blue[700], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
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
          'Bosqich $_currentStep/4',
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
            value: _currentStep / 4,
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
