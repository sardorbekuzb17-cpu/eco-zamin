import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/myid_config.dart' as app_config;

/// MyID Simple Authorization - Pasport ma'lumotlari bilan
///
/// Bu ekran Simple Authorization oqimini amalga oshiradi:
/// 1. Foydalanuvchidan pasport ma'lumotlarini olish
/// 2. Backend orqali access token olish
/// 3. Pasport bilan session yaratish
/// 4. SDK ni ishga tushirish
/// 5. Code olish va profil ma'lumotlarini olish
class MyIdSimpleAuthScreen extends StatefulWidget {
  const MyIdSimpleAuthScreen({super.key});

  @override
  State<MyIdSimpleAuthScreen> createState() => _MyIdSimpleAuthScreenState();
}

class _MyIdSimpleAuthScreenState extends State<MyIdSimpleAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passportController = TextEditingController();
  final _birthDateController = TextEditingController();

  bool _isLoading = false;
  String _statusMessage = '';
  int _currentStep = 0;

  static const String _backendUrl =
      'https://greenmarket-backend-lilac.vercel.app';

  @override
  void dispose() {
    _passportController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  /// To'liq Simple Authorization oqimi - BARCHA SO'ROVLAR BACKEND ORQALI
  Future<void> _startSimpleAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _currentStep = 1;
      _statusMessage = 'Backend orqali session yaratilmoqda...';
    });

    try {
      // 1-2. Backend orqali session yaratish (access token + session bitta so'rovda)
      if (kDebugMode) {
        debugPrint('🔵 [1/4] Backend orqali session yaratilmoqda...');
      }

      final sessionResponse = await http.post(
        Uri.parse('$_backendUrl/api/myid/create-session-with-passport'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'pass_data': _passportController.text.trim(),
          'birth_date': _birthDateController.text.trim(),
        }),
      );

      if (sessionResponse.statusCode != 200) {
        throw Exception('Session yaratishda xato: ${sessionResponse.body}');
      }

      final sessionData = json.decode(sessionResponse.body);
      final sessionId = sessionData['data']['session_id'];

      if (kDebugMode) {
        debugPrint('✅ [1/4] Session yaratildi: $sessionId');
      }

      // 2. SDK ni ishga tushirish
      setState(() {
        _currentStep = 2;
        _statusMessage = 'MyID SDK ishga tushirilmoqda...';
      });

      if (kDebugMode) {
        debugPrint('🔵 [2/4] SDK ishga tushirilmoqda...');
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
        'auth_method': 'simple_authorization',
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

  /// Sana tanlash
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
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
          'MyID Simple Authorization',
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
          child: _isLoading ? _buildProgressView() : _buildFormView(),
        ),
      ),
    );
  }

  /// Forma ko'rinishi
  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            'Pasport ma\'lumotlarini kiriting',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MyID orqali identifikatsiya qilish uchun',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Pasport seriyasi va raqami
          TextFormField(
            controller: _passportController,
            decoration: InputDecoration(
              labelText: 'Pasport seriyasi va raqami',
              hintText: 'AA1234567',
              prefixIcon: const Icon(Icons.badge),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pasport ma\'lumotlarini kiriting';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Tug'ilgan sana
          TextFormField(
            controller: _birthDateController,
            decoration: InputDecoration(
              labelText: 'Tug\'ilgan sana',
              hintText: 'YYYY-MM-DD',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            readOnly: true,
            onTap: _selectDate,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tug\'ilgan sanani tanlang';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Davom etish tugmasi
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _startSimpleAuth,
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
                    'Pasport ma\'lumotlaringiz xavfsiz shifrlangan holda saqlanadi va faqat identifikatsiya uchun ishlatiladi.',
                    style: TextStyle(color: Colors.blue[700], fontSize: 13),
                  ),
                ),
              ],
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
