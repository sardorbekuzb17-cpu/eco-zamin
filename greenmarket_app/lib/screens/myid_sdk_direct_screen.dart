import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/myid_config.dart' as app_config;

/// MyID SDK To'g'ridan-To'g'ri - Backend'siz
///
/// Bu ekran SDK'ni to'g'ridan-to'g'ri ishlatadi:
/// 1. SDK'ni ishga tushirish (sessionId siz)
/// 2. SDK o'zi hamma narsani boshqaradi
/// 3. Code olish va saqlash
class MyIdSdkDirectScreen extends StatefulWidget {
  const MyIdSdkDirectScreen({super.key});

  @override
  State<MyIdSdkDirectScreen> createState() => _MyIdSdkDirectScreenState();
}

class _MyIdSdkDirectScreenState extends State<MyIdSdkDirectScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  /// SDK'ni to'g'ridan-to'g'ri ishga tushirish
  Future<void> _startSdk() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'MyID SDK ishga tushirilmoqda...';
    });

    try {
      if (kDebugMode) {
        debugPrint(
          '🔵 [1/3] SDK to\'g\'ridan-to\'g\'ri ishga tushirilmoqda...',
        );
      }

      // SDK'ni sessionId siz ishga tushirish
      final config = MyIdConfig(
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
        debugPrint('✅ [1/3] SDK natija:');
        debugPrint('   - code: ${result.code}');
        debugPrint('   - base64: ${result.base64?.length ?? 0} bytes');
      }

      if (result.code == null || result.code!.isEmpty) {
        throw Exception('SDK code null yoki bo\'sh');
      }

      // Backend'ga profil ma'lumotlarini yuborish
      setState(() {
        _statusMessage = 'Backend\'ga ma\'lumotlar yuborilmoqda...';
      });

      if (kDebugMode) {
        debugPrint('🔵 [2/3] Backend\'ga so\'rov yuborilmoqda...');
      }

      final response = await http.post(
        Uri.parse(
          'https://greenmarket-backend-lilac.vercel.app/api/myid/get-user-info',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': result.code, 'base64_image': result.base64}),
      );

      if (response.statusCode != 200) {
        throw Exception('Backend xatosi: ${response.body}');
      }

      final backendData = json.decode(response.body);

      if (kDebugMode) {
        debugPrint('✅ [2/3] Backend javob olindi');
        debugPrint('   - User ID: ${backendData['data']['user_id']}');
        debugPrint('   - PINFL: ${backendData['data']['pinfl']}');
      }

      // Ma'lumotlarni saqlash
      setState(() {
        _statusMessage = 'Ma\'lumotlar saqlanmoqda...';
      });

      if (kDebugMode) {
        debugPrint('🔵 [3/3] Ma\'lumotlar saqlanmoqda...');
      }

      final userData = {
        'pinfl': result.code,
        'user_id': backendData['data']['user_id'],
        'profile': backendData['data']['profile'],
        'verified': true,
        'timestamp': DateTime.now().toIso8601String(),
        'auth_method': 'sdk_direct',
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(userData));

      if (kDebugMode) {
        debugPrint('✅ [3/3] Muvaffaqiyatli yakunlandi!');
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
          'MyID SDK To\'g\'ridan-To\'g\'ri',
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
          'SDK To\'g\'ridan-To\'g\'ri',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2E1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Backend\'siz, SDK o\'zi hamma narsani boshqaradi',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),

        // Davom etish tugmasi
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startSdk,
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
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bu eng oddiy usul - SDK o\'zi session yaratadi, pasport so\'raydi va identifikatsiya qiladi. Backend kerak emas!',
                  style: TextStyle(color: Colors.green[700], fontSize: 13),
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

        // Holat xabari
        Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2E1A),
          ),
        ),
        const SizedBox(height: 32),

        // Loading indikator
        const CircularProgressIndicator(color: Color(0xFF0066cc)),
      ],
    );
  }
}
