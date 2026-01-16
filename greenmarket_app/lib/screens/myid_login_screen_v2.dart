import 'package:flutter/material.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'home_screen.dart';

class MyIDLoginScreenV2 extends StatefulWidget {
  const MyIDLoginScreenV2({super.key});

  @override
  State<MyIDLoginScreenV2> createState() => _MyIDLoginScreenV2State();
}

class _MyIDLoginScreenV2State extends State<MyIDLoginScreenV2> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> _loginWithMyID() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // UUID formatida sessionId yaratish
      const uuid = Uuid();
      final sessionId = uuid.v4();
      const clientHash =
          'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5wQYaS8i1b0Rj5wuJLhIyDuTW/WoWB/kRbJCBHFLyFTxETADNa/CU+xw0moN9X10+MVD5kRMinMRQpGUVCrUXjUAEjwbdaCSLR6suRYI1EfDMQ5XFdJsfkAlNzZyyfBlif4OA4qxaMtdyvJCa/8nwHn2KC89BNhqBQMre7iLaW8Z9bArSulSxBJzbzPjd7Jkg4ccQ47bVyjEKBcu/1KXUd/audUr1WsUpBf9yvgSTDRG2cuVXpMGEBJAqrsCS3RtIt7pEnGtr5FsB+UmBec9Ei97fK2LcVfWpc/m7WjWMz3mku/pmhSjC6Vl6dlOrP1dv/fJkhfh3axzXtZoxgV1QwIDAQAB';
      const clientHashId = 'ac6d0f4a-5d5b-44e3-a865-9159a3146a8c';

      final myIdResult = await MyIdClient.start(
        config: MyIdConfig(
          sessionId: sessionId,
          clientHash: clientHash,
          clientHashId: clientHashId,
          environment: MyIdEnvironment.PRODUCTION,
          entryType: MyIdEntryType.IDENTIFICATION,
        ),
      );

      if (myIdResult.code != null) {
        final userData = {
          'code': myIdResult.code,
          'timestamp': DateTime.now().toIso8601String(),
        };

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(userData));
        await prefs.setString('myid_code', myIdResult.code!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('MyID muvaffaqiyatli!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'MyID bekor qilindi';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Xatolik: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌱', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      const Text(
                        'GreenMarket',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2ecc71),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ekologik bozor platformasiga xush kelibsiz',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _loginWithMyID,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066cc),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'ID',
                                        style: TextStyle(
                                          color: Color(0xFF0066cc),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
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

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'MyID ilovasini telefoningizga o\'rnatgan bo\'lishingiz kerak',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
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
          ),
        ),
      ),
    );
  }
}
