import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/myid_oauth_service.dart';

class MyIdCompleteLoginScreen extends StatefulWidget {
  const MyIdCompleteLoginScreen({super.key});

  @override
  State<MyIdCompleteLoginScreen> createState() =>
      _MyIdCompleteLoginScreenState();
}

class _MyIdCompleteLoginScreenState extends State<MyIdCompleteLoginScreen> {
  bool _isLoading = false;
  String? _statusMessage;
  String? _errorMessage;

  // Ixtiyoriy parametrlar
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _passDataController = TextEditingController();
  bool _useOptionalParams = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _birthDateController.dispose();
    _passDataController.dispose();
    super.dispose();
  }

  Future<void> _startCompleteAuthFlow() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ESKI MA'LUMOTLARNI O'CHIRISH
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('myid_profile');
      await prefs.remove('myid_access_token');
      await prefs.remove('myid_session_id');
      await prefs.remove('user_data');

      // BIRINCHI BO'SH SESSIYA YARATISH
      // Checkbox belgilanmagan bo'lsa, hech qanday parametr yuborilmaydi
      // Bu MyID SDK ga pasport kiritish ekranini ko'rsatishni bildiradi
      final result = await MyIdOAuthService.completeAuthFlow(
        phoneNumber: _useOptionalParams && _phoneController.text.isNotEmpty
            ? _phoneController.text
            : null,
        birthDate: _useOptionalParams && _birthDateController.text.isNotEmpty
            ? _birthDateController.text
            : null,
        passData: _useOptionalParams && _passDataController.text.isNotEmpty
            ? _passDataController.text
            : null,
        isResident: _useOptionalParams ? true : null,
        threshold: _useOptionalParams ? 0.75 : null,
        onStatusUpdate: (status) {
          setState(() => _statusMessage = status);
        },
      );

      if (result['success'] == true) {
        // Ma'lumotlarni saqlash
        final prefs = await SharedPreferences.getInstance();

        // Profil ma'lumotlarini saqlash
        await prefs.setString('myid_profile', json.encode(result['profile']));

        // Access token va session ID ni saqlash
        await prefs.setString('myid_access_token', result['access_token']);
        await prefs.setString('myid_session_id', result['session_id']);

        // Eski formatdagi ma'lumotlarni ham saqlash (backward compatibility)
        final userData = {
          'session_id': result['session_id'],
          'profile': result['profile'],
          'data': result['data'],
          'comparison_value': result['comparison_value'],
          'pers_data': result['pers_data'],
          'pin_id': result['pin_id'],
          'timestamp': DateTime.now().toIso8601String(),
          'verified': true,
        };
        await prefs.setString('user_data', json.encode(userData));

        if (mounted) {
          // Profil sahifasiga o'tish
          Navigator.pushReplacementNamed(context, '/profile');
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Noma\'lum xatolik';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Xatolik: ${e.toString()}';
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
      appBar: AppBar(
        title: const Text('MyID OAuth Login'),
        backgroundColor: const Color(0xFF15803D),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF15803D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.eco, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),

              // Sarlavha
              const Text(
                'GreenMarket',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'MyID OAuth - Bo\'sh sessiya rejimi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Ixtiyoriy parametrlar
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _useOptionalParams,
                            onChanged: (value) {
                              setState(() => _useOptionalParams = value!);
                            },
                          ),
                          const Text('Qo\'shimcha parametrlar'),
                        ],
                      ),
                      if (_useOptionalParams) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Telefon raqami',
                            hintText: '998901234567',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _birthDateController,
                          decoration: const InputDecoration(
                            labelText: 'Tug\'ilgan sana',
                            hintText: '1990-01-01',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passDataController,
                          decoration: const InputDecoration(
                            labelText: 'Pasport ma\'lumotlari',
                            hintText: 'AA1234567',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status xabari
              if (_statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Login tugmasi
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startCompleteAuthFlow,
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

              // Ma'lumot
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        Text(
                          'BO\'SH SESSIYA REJIMI',
                          style: TextStyle(
                            color: Colors.amber[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Checkbox belgilanmagan bo\'lsa:\n'
                      '• Hech qanday parametr yuborilmaydi\n'
                      '• MyID SDK pasport kiritish ekranini ko\'rsatadi\n'
                      '• Foydalanuvchi pasport ma\'lumotlarini kiritadi\n\n'
                      'Checkbox belgilangan bo\'lsa:\n'
                      '• Kiritilgan parametrlar yuboriladi\n'
                      '• SDK to\'g\'ridan-to\'g\'ri yuz tanishga o\'tadi',
                      style: TextStyle(color: Colors.amber[900], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Jarayon qadamlari',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStep('1', 'Access token olish'),
                    _buildStep('2', 'Bo\'sh sessiya yaratish'),
                    _buildStep('3', 'Pasport ma\'lumotlarini kiritish'),
                    _buildStep('4', 'Yuz tanish'),
                    _buildStep('5', 'Profil ma\'lumotlarini olish'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.green[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
