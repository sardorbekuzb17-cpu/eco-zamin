import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// MyID API Flow - Dokumentatsiyaga muvofiq
/// 1. Access token olish
/// 2. Pasport + selfie yuborish
/// 3. Natija olish
class MyIdApiFlowScreen extends StatefulWidget {
  const MyIdApiFlowScreen({super.key});

  @override
  State<MyIdApiFlowScreen> createState() => _MyIdApiFlowScreenState();
}

class _MyIdApiFlowScreenState extends State<MyIdApiFlowScreen> {
  final _passportController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  String? _statusMessage;
  String? _errorMessage;
  int _currentStep = 0;

  static const String _backendUrl =
      'https://greenmarket-backend-lilac.vercel.app';

  @override
  void dispose() {
    _passportController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // 100 dan 50 ga tushirdik
        maxWidth: 800, // Maksimal kenglik
        maxHeight: 800, // Maksimal balandlik
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Kamera xatosi: ${e.toString()}';
      });
    }
  }

  Future<void> _startApiFlow() async {
    // Validatsiya
    if (_passportController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Pasport seriya va raqamini kiriting';
      });
      return;
    }

    if (_birthDateController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Tug\'ilgan sanani kiriting (YYYY-MM-DD)';
      });
      return;
    }

    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Selfie oling';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentStep = 0;
    });

    try {
      // Rasmni base64 ga o'girish
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      // TO'LIQ SDK FLOW - bitta so'rovda
      setState(() {
        _statusMessage = 'SDK Flow boshlandi...';
        _currentStep = 1;
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/api/myid/complete'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'pass_data': _passportController.text.toUpperCase(),
          'birth_date': _birthDateController.text,
          'photo_base64': base64Image,
          'agreed_on_terms': true,
          'device': 'Flutter Mobile App',
          'threshold': 0.5,
          'is_resident': true,
        }),
      );

      debugPrint('📥 Backend javob: ${response.statusCode}');
      debugPrint('📥 Backend body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final resultCode = data['data']['result_code'];
          final resultNote = data['data']['result_note'];

          if (resultCode == 1) {
            // Muvaffaqiyatli!
            setState(() {
              _statusMessage = 'Muvaffaqiyatli! Ma\'lumotlar saqlandi.';
              _currentStep = 3;
            });

            // Ma'lumotlarni saqlash
            final prefs = await SharedPreferences.getInstance();
            final userData = {
              'job_id': data['job_id'],
              'profile': data['data']['profile'],
              'comparison_value': data['data']['comparison_value'],
              'timestamp': DateTime.now().toIso8601String(),
              'verified': true,
              'method': 'api_flow',
            };

            await prefs.setString('user_data', json.encode(userData));

            // 2 soniyadan keyin Home sahifasiga o'tish
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          } else {
            // MyID xatosi
            setState(() {
              _errorMessage =
                  'MyID xatosi (kod: $resultCode): $resultNote\n\nTafsilotlar:\n${_getErrorDescription(resultCode)}';
              _currentStep = 0;
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Backend xatosi: ${data['error']}';
            _currentStep = 0;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Backend xatosi: ${response.statusCode}\n${response.body}';
          _currentStep = 0;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Kutilmagan xatolik: ${e.toString()}';
        _currentStep = 0;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getErrorDescription(int code) {
    switch (code) {
      case 2:
        return 'Pasport ma\'lumotlari noto\'g\'ri kiritildi';
      case 3:
        return 'Hayotiylikni tasdiqlay olmadi';
      case 4:
        return 'Tanib bo\'lmadi';
      case 14:
        return 'Yuzni ajratib bo\'lmadi (surat sifati yomon)';
      case 17:
        return 'Yuzlarni solishtirish xatosi';
      case 20:
        return 'Yomon yoki xira tasvir';
      case 21:
        return 'Yuz to\'liq ramkada emas';
      case 22:
        return 'Kadrda bir nechta yuzlar bor';
      case 26:
        return 'Ko\'zlar yumilgan yoki ko\'rinmaydi';
      case 27:
        return 'Bosh aylanishi aniqlandi';
      default:
        return 'Noma\'lum xato';
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
          'MyID - SDK Flow',
          style: TextStyle(
            color: Color(0xFF1A2E1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2E1A)),
          onPressed: () => Navigator.pop(context),
        ),
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
                    color: const Color(0xFF0066cc),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066cc).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'ID',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'MyID SDK Flow',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dokumentatsiyaga muvofiq',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Progress indicator
              if (_currentStep > 0) ...[
                LinearProgressIndicator(
                  value: _currentStep / 3,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0066cc),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Qadam $_currentStep / 3',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
              ],

              // Status message
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

              // Pasport input
              TextField(
                controller: _passportController,
                decoration: InputDecoration(
                  labelText: 'Pasport seriya va raqami',
                  hintText: 'AA1234567',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),

              // Birth date input
              TextField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: 'Tug\'ilgan sana',
                  hintText: '1990-01-01',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Selfie button
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  _selectedImage == null ? 'Selfie oling' : 'Selfie olindi ✓',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: BorderSide(
                    color: _selectedImage == null ? Colors.grey : Colors.green,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Selfie preview
              if (_selectedImage != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _startApiFlow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066cc),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Tasdiqlash',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              // Error message
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

              const SizedBox(height: 24),

              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'API Flow',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu usulda backend client_id va client_secret bilan MyID API ga murojaat qiladi.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selfie talablari:\n• Yuz to\'liq ko\'rinishi kerak\n• Yaxshi yoritilgan joy\n• Ko\'zlar ochiq\n• Bosh to\'g\'ri',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
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
