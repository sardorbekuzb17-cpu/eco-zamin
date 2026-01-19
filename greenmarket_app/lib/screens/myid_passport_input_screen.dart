import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/myid_backend_client.dart';

class MyIdPassportInputScreen extends StatefulWidget {
  const MyIdPassportInputScreen({super.key});

  @override
  State<MyIdPassportInputScreen> createState() =>
      _MyIdPassportInputScreenState();
}

class _MyIdPassportInputScreenState extends State<MyIdPassportInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passportSeriesController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _birthDateController = TextEditingController();

  bool _isLoading = false;
  String? _statusMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _passportSeriesController.dispose();
    _passportNumberController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _submitPassport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Backend'dan pasport bilan sessiya olish
      setState(() => _statusMessage = 'Backend\'dan sessiya olinmoqda...');

      final passportData =
          '${_passportSeriesController.text.trim()}${_passportNumberController.text.trim()}';

      final sessionResult = await MyIdBackendClient.createSessionWithPassport(
        passData: passportData,
        birthDate: _birthDateController.text.trim(),
        isResident: true,
      );

      if (sessionResult['success'] != true) {
        setState(() {
          _errorMessage =
              sessionResult['error'] ?? 'Sessiya yaratishda xatolik';
        });
        return;
      }

      final sessionId = sessionResult['data']['session_id'];

      // 2. SDK'ni ishga tushirish
      setState(() => _statusMessage = 'MyID SDK ishga tushirilmoqda...');

      final sdkResult = await MyIdBackendClient.startSDK(sessionId: sessionId);

      if (sdkResult['success'] != true) {
        setState(() {
          _errorMessage = 'SDK xatosi: ${sdkResult['error']}';
        });
        return;
      }

      // 3. Muvaffaqiyatli
      final prefs = await SharedPreferences.getInstance();
      final userData = {
        'session_id': sessionId,
        'code': sdkResult['code'],
        'passport_series': _passportSeriesController.text.trim(),
        'passport_number': _passportNumberController.text.trim(),
        'birth_date': _birthDateController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
        'verified': true,
        'method': 'passport_input',
      };

      await prefs.setString('user_data', json.encode(userData));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
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
        title: const Text('Pasport ma\'lumotlari'),
        backgroundColor: const Color(0xFF15803D),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
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
                    child: const Icon(
                      Icons.badge,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sarlavha
                const Text(
                  'Pasport ma\'lumotlarini kiriting',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2E1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ma\'lumotlaringiz xavfsiz saqlanadi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Pasport seriyasi
                TextFormField(
                  controller: _passportSeriesController,
                  decoration: const InputDecoration(
                    labelText: 'Pasport seriyasi',
                    hintText: 'AA',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pasport seriyasini kiriting';
                    }
                    if (value.length != 2) {
                      return 'Seriya 2 ta harf bo\'lishi kerak';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Pasport raqami
                TextFormField(
                  controller: _passportNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Pasport raqami',
                    hintText: '1234567',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 7,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pasport raqamini kiriting';
                    }
                    if (value.length != 7) {
                      return 'Raqam 7 ta raqam bo\'lishi kerak';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tug'ilgan sana
                TextFormField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(
                    labelText: 'Tug\'ilgan sana',
                    hintText: '1990-01-01',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tug\'ilgan sanani kiriting';
                    }
                    // YYYY-MM-DD formatini tekshirish
                    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                    if (!regex.hasMatch(value)) {
                      return 'Format: YYYY-MM-DD (masalan: 1990-01-01)';
                    }
                    return null;
                  },
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

                // Yuborish tugmasi
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitPassport,
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
                        : const Text(
                            'Davom etish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Jarayon',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStep('1', 'Pasport ma\'lumotlarini kiriting'),
                      _buildStep('2', 'Backend sessiya yaratadi'),
                      _buildStep('3', 'MyID SDK ishga tushadi'),
                      _buildStep('4', 'Yuz tanish'),
                      _buildStep('5', 'Muvaffaqiyatli kirish'),
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
