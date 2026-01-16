import 'package:flutter/material.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/myid_backend_service.dart';

class MyIdPassportDirectLogin extends StatefulWidget {
  const MyIdPassportDirectLogin({super.key});

  @override
  State<MyIdPassportDirectLogin> createState() =>
      _MyIdPassportDirectLoginState();
}

class _MyIdPassportDirectLoginState extends State<MyIdPassportDirectLogin> {
  bool _isLoading = false;
  String? _errorMessage;

  // MyID credentials (shartnomadan)
  static const String clientHashId = 'ac6d0f4a-5d5b-44e3-a865-9159a3146a8c';
  static const String clientHash = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5wQYaS8i1b0Rj5wuJLhI
yDuTW/WoWB/kRbJCBHFLyFTxETADNa/CU+xw0moN9X10+MVD5kRMinMRQpGUVCrU
XjUAEjwbdaCSLR6suRYI1EfDMQ5XFdJsfkAlNzZyyfBlif4OA4qxaMtdyvJCa/8n
wHn2KC89BNhqBQMre7iLaW8Z9bArSulSxBJzbzPjd7Jkg4ccQ47bVyjEKBcu/1KX
Ud/audUr1WsUpBf9yvgSTDRG2cuVXpMGEBJAqrsCS3RtIt7pEnGtr5FsB+UmBec9
Ei97fK2LcVfWpc/m7WjWMz3mku/pmhSjC6Vl6dlOrP1dv/fJkhfh3axzXtZoxgV1
QwIDAQAB
-----END PUBLIC KEY-----''';

  Future<void> _startMyIdAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Backend dan BO'SH session ID olish
      final sessionResponse = await MyIdBackendService.createEmptySession();

      if (sessionResponse['success'] != true) {
        throw Exception('Backend xatosi: ${sessionResponse['error']}');
      }

      // Backend javob: {success: true, data: {success: true, data: {session_id: "..."}}}
      // MyID API javobi ichida yana bir data bor
      final outerData = sessionResponse['data'];
      if (outerData == null) {
        throw Exception('Backend javobida data yo\'q');
      }

      // MyID API ning ichki data si
      final innerData = outerData['data'];
      if (innerData == null) {
        throw Exception('MyID API javobida data yo\'q');
      }

      final sessionId = innerData['session_id'];
      if (sessionId == null) {
        final keys = innerData is Map
            ? innerData.keys.toList().toString()
            : 'Map emas';
        throw Exception(
          'session_id topilmadi.\nMavjud kalitlar: $keys\nTo\'liq innerData: $innerData',
        );
      }

      // 2. MyID SDK ni ishga tushirish
      final result = await MyIdClient.start(
        config: MyIdConfig(
          sessionId: sessionId.toString(),
          clientHash: clientHash,
          clientHashId: clientHashId,
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
                'MyID SDK pasport ma\'lumotlarini so\'raydi',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startMyIdAuth,
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
              const SizedBox(height: 32),
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
                        'MyID SDK pasport ma\'lumotlarini xavfsiz tarzda to\'playdi',
                        style: TextStyle(color: Colors.blue[700], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
