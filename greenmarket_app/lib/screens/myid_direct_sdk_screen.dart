import 'package:flutter/material.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyIdDirectSdkScreen extends StatefulWidget {
  const MyIdDirectSdkScreen({super.key});

  @override
  State<MyIdDirectSdkScreen> createState() => _MyIdDirectSdkScreenState();
}

class _MyIdDirectSdkScreenState extends State<MyIdDirectSdkScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // MyID SDK'ni to'g'ridan-to'g'ri ishga tushirish (session_id siz)
  Future<void> _startMyIdSdk() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // MyID SDK'ni ishga tushirish - FACE_DETECTION rejimida
      // Bu rejimda session_id kerak emas
      final result = await MyIdClient.start(
        config: MyIdConfig(
          clientHash:
              '''MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5wQYaS8i1b0Rj5wuJLhIyDuTW/WoWB/kRbJCBHFLyFTxETADNa/CU+xw0moN9X10+MVD5kRMinMRQpGUVCrUXjUAEjwbdaCSLR6suRYI1EfDMQ5XFdJsfkAlNzZyyfBlif4OA4qxaMtdyvJCa/8nwHn2KC89BNhqBQMre7iLaW8Z9bArSulSxBJzbzPjd7Jkg4ccQ47bVyjEKBcu/1KXUd/audUr1WsUpBf9yvgSTDRG2cuVXpMGEBJAqrsCS3RtIt7pEnGtr5FsB+UmBec9Ei97fK2LcVfWpc/m7WjWMz3mku/pmhSjC6Vl6dlOrP1dv/fJkhfh3axzXtZoxgV1QwIDAQAB''',
          clientHashId: 'ac6d0f4a-5d5b-44e3-a865-9159a3146a8c',
          environment: MyIdEnvironment.PRODUCTION,
          entryType: MyIdEntryType.FACE_DETECTION, // Session_id kerak emas
          locale: MyIdLocale.UZBEK,
        ),
        iosAppearance: const MyIdIOSAppearance(),
      );

      // Natijani qayta ishlash
      if (result.code != null) {
        await _handleMyIdResult(result);
      } else {
        setState(() {
          _errorMessage = 'MyID natija topilmadi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'MyID SDK xatosi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // MyID natijasini qayta ishlash
  Future<void> _handleMyIdResult(MyIdResult result) async {
    try {
      // User ma'lumotlarini saqlash
      final userData = {
        'user_id': result.code ?? 'unknown',
        'full_name': 'MyID User',
        'verified': true,
        'timestamp': DateTime.now().toIso8601String(),
        'myid_code': result.code,
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(userData));

      if (mounted) {
        // Home sahifasiga o'tish
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF15803D),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.eco, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'GreenMarket',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2E1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MyID SDK orqali tizimga kiring',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 48),

                // MyID tugmasi
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _startMyIdSdk,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066cc),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
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
                                'MyID orqali kirish',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // Xato xabari
                if (_errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Ma'lumot
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bu versiya faqat yuz identifikatsiyasini tekshiradi (FACE_DETECTION rejimi)',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
