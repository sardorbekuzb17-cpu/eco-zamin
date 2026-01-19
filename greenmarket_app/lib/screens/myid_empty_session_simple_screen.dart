import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/myid_config.dart' as app_config;

/// Bo'sh Session - 3 Qatorli Sodda Versiya
class MyIdEmptySessionSimpleScreen extends StatefulWidget {
  const MyIdEmptySessionSimpleScreen({super.key});

  @override
  State<MyIdEmptySessionSimpleScreen> createState() =>
      _MyIdEmptySessionSimpleScreenState();
}

class _MyIdEmptySessionSimpleScreenState
    extends State<MyIdEmptySessionSimpleScreen> {
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
      _statusMessage = 'Session yaratilmoqda...';
    });

    try {
      // 1. Backend orqali bo'sh session yaratish
      if (kDebugMode) {
        debugPrint('🔵 [1/3] Backend orqali bo\'sh session yaratilmoqda...');
      }

      final sessionResponse = await http.post(
        Uri.parse('$_backendUrl/api/myid/create-session'),
        headers: {'Content-Type': 'application/json'},
      );

      if (sessionResponse.statusCode != 200) {
        throw Exception('Session yaratishda xato: ${sessionResponse.body}');
      }

      final sessionData = json.decode(sessionResponse.body);
      final sessionId = sessionData['data']['session_id'];

      if (kDebugMode) {
        debugPrint('✅ [1/3] Session yaratildi: $sessionId');
      }

      // 2. SDK ni ishga tushirish
      setState(() {
        _currentStep = 2;
        _statusMessage = 'MyID SDK ishga tushirilmoqda...';
      });

      if (kDebugMode) {
        debugPrint('🔵 [2/3] SDK ishga tushirilmoqda...');
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
        debugPrint('✅ [2/3] SDK natija: code=${result.code}');
      }

      if (result.code == null || result.code!.isEmpty) {
        throw Exception('SDK code null yoki bo\'sh');
      }

      // 3. Profil ma'lumotlarini olish va saqlash
      setState(() {
        _currentStep = 3;
        _statusMessage = 'Ma\'lumotlar saqlanmoqda...';
      });

      if (kDebugMode) {
        debugPrint('🔵 [3/3] Profil ma\'lumotlari olinmoqda...');
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
        debugPrint('✅ [3/3] Muvaffaqiyatli yakunlandi!');
      }

      setState(() {
        _statusMessage = 'Muvaffaqiyatli!';
      });

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
        child: Center(
          child: _isLoading ? _buildProgressView() : _buildButtonView(),
        ),
      ),
    );
  }

  /// Tugma ko'rinishi
  Widget _buildButtonView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
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
            'Hech qanday ma\'lumot kiritmasdan session yarating',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 48),

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
                'Davom etish',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Jarayon ko'rinishi
  Widget _buildProgressView() {
    return Column(
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

        // Bosqich
        Text(
          'Bosqich $_currentStep/3',
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
          width: 200,
          child: LinearProgressIndicator(
            value: _currentStep / 3,
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
