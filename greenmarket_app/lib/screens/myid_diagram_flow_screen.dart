import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/myid_backend_client.dart';

/// MyID Diagram Flow Screen
/// Chizmaga muvofiq to'liq jarayon:
/// 1. Client Backend → access_token oladi
/// 2. Client Backend → bo'sh sessiya yaratadi (without passport)
/// 3. Mobile APP → session_id oladi
/// 4. Mobile APP → SDK'ni ishga tushiradi
/// 5. MyID SDK → pasport ma'lumotlarini so'raydi
/// 6. MyID SDK → selfie va pasport ma'lumotlarini yuboradi
/// 7. MyID Backend → natijani qaytaradi
/// 8. Mobile APP → ma'lumotlarni Client Backend'ga yuboradi
class MyIdDiagramFlowScreen extends StatefulWidget {
  const MyIdDiagramFlowScreen({super.key});

  @override
  State<MyIdDiagramFlowScreen> createState() => _MyIdDiagramFlowScreenState();
}

class _MyIdDiagramFlowScreenState extends State<MyIdDiagramFlowScreen> {
  bool _isLoading = false;
  String _currentStep = '';
  String? _errorMessage;
  final List<String> _steps = [];

  Future<void> _startDiagramFlow() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _steps.clear();
      _currentStep = '';
    });

    try {
      // TO'G'RI USUL - dokumentatsiyaga muvofiq
      final result = await MyIdBackendClient.completeAuthFlow(
        onStatusUpdate: (status) {
          setState(() {
            _currentStep = status;
            _steps.add('✅ $status');
          });
        },
      );

      if (result['success'] == true) {
        // Muvaffaqiyatli - ma'lumotlarni saqlash
        final prefs = await SharedPreferences.getInstance();
        final userData = {
          'code': result['code'],
          'user_data': result['user_data'],
          'timestamp': DateTime.now().toIso8601String(),
          'verified': true,
        };

        await prefs.setString('user_data', json.encode(userData));

        setState(() {
          _steps.add('✅ Ma\'lumotlar saqlandi');
          _steps.add('✅ Muvaffaqiyatli autentifikatsiya!');
        });

        // Home sahifasiga o'tish
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Noma\'lum xatolik';
          _steps.add('❌ Xatolik: $_errorMessage');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _steps.add('❌ Kutilmagan xatolik: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
        _currentStep = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('MyID - Chizma bo\'yicha'),
        backgroundColor: const Color(0xFF15803D),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sarlavha
              const Text(
                'MyID Autentifikatsiya',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chizmaga muvofiq to\'liq jarayon',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Jarayon tushuntirish
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Mobile → SDK\'ni ishga tushiradi\n'
                      '2. SDK → pasport ekranini ko\'rsatadi\n'
                      '3. SDK → pasport va selfie yuboradi\n'
                      '4. MyID → code qaytaradi\n'
                      '5. Backend → access_token oladi\n'
                      '6. Backend → foydalanuvchi ma\'lumotlarini oladi\n'
                      '7. Mobile → ma\'lumotlarni saqlaydi',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Boshlash tugmasi
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startDiagramFlow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                      : const Text(
                          'Boshlash',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Joriy qadam
              if (_currentStep.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _currentStep,
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Qadamlar ro'yxati
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: _steps.isEmpty
                      ? Center(
                          child: Text(
                            'Jarayon boshlanmagan',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _steps.length,
                          itemBuilder: (context, index) {
                            final step = _steps[index];
                            final isError = step.startsWith('❌');
                            final isSuccess = step.startsWith('✅');

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    isError
                                        ? Icons.error
                                        : isSuccess
                                        ? Icons.check_circle
                                        : Icons.info,
                                    size: 20,
                                    color: isError
                                        ? Colors.red
                                        : isSuccess
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      step.substring(
                                        2,
                                      ), // Emoji'ni olib tashlash
                                      style: TextStyle(
                                        color: isError
                                            ? Colors.red[700]
                                            : isSuccess
                                            ? Colors.green[700]
                                            : Colors.blue[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),

              // Xato xabari
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Xatolik',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700], fontSize: 13),
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
}
