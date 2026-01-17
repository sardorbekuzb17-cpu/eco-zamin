import 'package:flutter/material.dart';
import '../services/myid_oauth_service.dart';

class MyIdOAuthLoginScreen extends StatefulWidget {
  const MyIdOAuthLoginScreen({super.key});

  @override
  State<MyIdOAuthLoginScreen> createState() => _MyIdOAuthLoginScreenState();
}

class _MyIdOAuthLoginScreenState extends State<MyIdOAuthLoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _startLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // To'liq OAuth jarayonini boshlash
      final result = await MyIdOAuthService.completeAuthFlow(
        onStatusUpdate: (status) {
          if (mounted) {
            setState(() {
              // Status xabarini ko'rsatish mumkin
            });
          }
        },
      );

      if (result['success'] == true && mounted) {
        // Muvaffaqiyatli - profil ekraniga o'tish
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Noma\'lum xatolik';
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
                  'MyID orqali tizimga kiring',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 48),

                // MyID tugmasi
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _startLogin,
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
                          'MyID - O\'zbekiston Respublikasining rasmiy identifikatsiya tizimi',
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
