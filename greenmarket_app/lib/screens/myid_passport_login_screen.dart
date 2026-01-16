import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/myid_backend_service.dart';

class MyIdPassportLoginScreen extends StatefulWidget {
  const MyIdPassportLoginScreen({super.key});

  @override
  State<MyIdPassportLoginScreen> createState() =>
      _MyIdPassportLoginScreenState();
}

class _MyIdPassportLoginScreenState extends State<MyIdPassportLoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _acceptTerms = false;

  final TextEditingController _passportSeriesController =
      TextEditingController();
  final TextEditingController _passportNumberController =
      TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  @override
  void dispose() {
    _passportSeriesController.dispose();
    _passportNumberController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _verifyPassport() async {
    // Validatsiya
    if (_passportSeriesController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Pasport seriyasini kiriting';
      });
      return;
    }

    if (_passportNumberController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Pasport raqamini kiriting';
      });
      return;
    }

    if (_birthDateController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Tug\'ilgan kunni kiriting';
      });
      return;
    }

    if (!_acceptTerms) {
      setState(() {
        _errorMessage = 'Shartlarni qabul qilishingiz kerak';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Pasport ma'lumotlarini formatlash
      final passportSeries = _passportSeriesController.text
          .trim()
          .toUpperCase();
      final passportNumber = _passportNumberController.text.trim();
      final birthDate = _birthDateController.text.trim();

      // Backend orqali pasport tekshirish
      final response = await MyIdBackendService.verifyPassport(
        passportSeries: passportSeries,
        passportNumber: passportNumber,
        birthDate: birthDate,
      );

      if (response['success'] == true) {
        // Muvaffaqiyatli
        final userData = {
          'passport': '$passportSeries$passportNumber',
          'birth_date': birthDate,
          'timestamp': DateTime.now().toIso8601String(),
          'verified': true,
          'verification_data': response['data'],
        };

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(userData));

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Xatolik
        setState(() {
          _errorMessage = 'Pasport tekshiruvida xatolik: ${response['error']}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Xatolik: ${e.toString()}';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title
              const Text(
                'Ro\'yxatdan o\'tish',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              // Pasport seriyasi va raqami
              const Text(
                'Pasport seriyasi va raqami yoki JSHSHIR',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Seriya
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _passportSeriesController,
                      decoration: InputDecoration(
                        hintText: 'AA',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF15803D),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 2,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Raqam
                  Expanded(
                    child: TextField(
                      controller: _passportNumberController,
                      decoration: InputDecoration(
                        hintText: '1234567 | JSHSHIR',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF15803D),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        suffixIcon: Icon(
                          Icons.qr_code_scanner,
                          color: Colors.grey[600],
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tug'ilgan kun
              const Text(
                'Tug\'ilgan kun',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  hintText: 'kk.oo.yyyy',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF15803D),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.datetime,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _birthDateController.text =
                        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                  }
                },
                readOnly: true,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Shartlar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF15803D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Men shartlarni qabul qilaman\n',
                          ),
                          TextSpan(
                            text: 'Foydalanuvchi kelishuvi',
                            style: TextStyle(
                              color: Colors.blue[700],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' va '),
                          TextSpan(
                            text: 'Maxfiylik siyosati',
                            style: TextStyle(
                              color: Colors.blue[700],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Keyingi tugmasi
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPassport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey[200],
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Keyingi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Men norezidentman
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Men norezidentman',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // MyID logo
              Center(
                child: Image.asset(
                  'assets/images/myid_logo.png',
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'MyID',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B4EFF),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'safe identification',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
