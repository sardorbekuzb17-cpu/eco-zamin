import 'package:flutter/material.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/myid_backend_service.dart';
import '../config/myid_config.dart' as app_config;

class MyIdOAuthFullLoginScreen extends StatefulWidget {
  const MyIdOAuthFullLoginScreen({super.key});

  @override
  State<MyIdOAuthFullLoginScreen> createState() =>
      _MyIdOAuthFullLoginScreenState();
}

class _MyIdOAuthFullLoginScreenState extends State<MyIdOAuthFullLoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _statusMessage;

  // MyID credentials
  static const String clientHash = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5wQYaS8i1b0Rj5wuJLhI
yDuTW/WoWB/kRbJCBHFLyFTxETADNa/CU+xw0moN9X10+MVD5kRMinMRQpGUVCrU
XjUAEjwbdaCSLR6suRYI1EfDMQ5XFdJsfkAlNzZyyfBlif4OA4qxaMtdyvJCa/8n
wHn2KC89BNhqBQMre7iLaW8Z9bArSulSxBJzbzPjd7Jkg4ccQ47bVyjEKBcu/1KX
Ud/audUr1WsUpBf9yvgSTDRG2cuVXpMGEBJAqrsCS3RtIt7pEnGtr5FsB+UmBec9
Ei97fK2LcVfWpc/m7WjWMz3mku/pmhSjC6Vl6dlOrP1dv/fJkhfh3axzXtZoxgV1
QwIDAQAB
-----END PUBLIC KEY-----''';

  Future<void> _startFullAuthFlow() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = 'Access token olinmoqda...';
    });

    try {
      // 1. Access token va sessiya yaratish
      setState(() => _statusMessage = 'Sessiya yaratilmoqda...');

      final sessionResponse = await MyIdBackendService.createSessionWithToken(
        clientId: app_config.MyIDConfig.clientId,
        clientSecret: app_config.MyIDConfig.clientSecret,
        // Ixtiyoriy parametrlar:
        // phoneNumber: '998901234567',
        // birthDate: '1990-01-01',
        // isResident: true,
        // pinfl: '12345678901234',
        // threshold: 0.75,
      );

      if (sessionResponse['success'] != true) {
        throw Exception(
          'Sessiya yaratishda xatolik: ${sessionResponse['error']}',
        );
      }

      final sessionId = sessionResponse['session_id'] as String;

      // 2. MyID SDK ni ishga tushirish
      setState(() => _statusMessage = 'MyID SDK ishga tushirilmoqda...');

      final result = await MyIdClient.start(
        config: MyIdConfig(
          sessionId: sessionId,
          clientHash: clientHash,
          clientHashId: app_config.MyIDConfig.clientHashId,
          environment: MyIdEnvironment.DEBUG,
          entryType: MyIdEntryType.IDENTIFICATION,
          locale: MyIdLocale.UZBEK,
        ),
        iosAppearance: const MyIdIOSAppearance(),
      );

      // 3. Natijani tekshirish
      if (result.code == '0') {
        final userData = {
          'myid_code': result.code,
          'session_id': sessionId,
          'timestamp': DateTime.now().toIso8601String(),
          'verified': true,
        };

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(userData));

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          _errorMessage = 'MyID xatosi: ${result.code}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
        _statusMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
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
                'MyID OAuth to\'liq jarayoni',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),

              // Jarayon qadamlari
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Jarayon qadamlari',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStep('1', 'Access token olish', Colors.blue),
                    _buildStep('2', 'Sessiya yaratish', Colors.blue),
                    _buildStep('3', 'MyID SDK ishga tushirish', Colors.blue),
                    _buildStep('4', 'Yuz tanish', Colors.green),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Status xabari
              if (_statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(color: Colors.orange[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Kirish tugmasi
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startFullAuthFlow,
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
                              'MyID OAuth orqali kirish',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Xatolik
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: color[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color[700], fontSize: 13)),
        ],
      ),
    );
  }
}
