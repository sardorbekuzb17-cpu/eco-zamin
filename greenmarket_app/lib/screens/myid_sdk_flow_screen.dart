import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';
import 'package:myid/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

/// MyID SDK Flow ekrani
///
/// Bu ekran to'liq MyID autentifikatsiya jarayonini boshqaradi:
/// 1. Sessiya yaratish (1/4)
/// 2. SDK ishga tushirish (2/4)
/// 3. Yuz tanish (3/4)
/// 4. Ma'lumotlarni saqlash (4/4)
///
/// Requirements: 8.2, 8.3
class MyIdSdkFlowScreen extends StatefulWidget {
  const MyIdSdkFlowScreen({super.key});

  @override
  State<MyIdSdkFlowScreen> createState() => _MyIdSdkFlowScreenState();
}

class _MyIdSdkFlowScreenState extends State<MyIdSdkFlowScreen> {
  // Jarayon holati
  int _currentStep = 1; // 1-4
  bool _isLoading = false;
  String? _errorMessage;
  String? _sessionId;
  String _statusMessage = 'Sessiya yaratilmoqda...';

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  /// To'liq oqimni boshlash
  Future<void> _startFlow() async {
    await _createSession();
  }

  /// Bosqich 1: Sessiya yaratish (1/4) - UUID bilan
  Future<void> _createSession() async {
    setState(() {
      _currentStep = 1;
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = 'Sessiya yaratilmoqda...';
    });

    try {
      if (kDebugMode) {
        debugPrint('🔵 [1/4] Sessiya yaratish boshlandi (UUID bilan)');
      }

      // UUID formatida sessionId yaratish
      const uuid = Uuid();
      final sessionId = uuid.v4();

      setState(() {
        _sessionId = sessionId;
      });

      if (kDebugMode) {
        debugPrint('✅ [1/4] Sessiya yaratildi: $sessionId');
      }

      // Keyingi bosqichga o'tish
      await Future.delayed(const Duration(milliseconds: 500));
      await _startMyIdSdk();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 [1/4] Sessiya yaratishda xato: $e');
      }
      setState(() {
        _errorMessage = 'Sessiya yaratishda xato: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Bosqich 2: SDK ishga tushirish (2/4)
  Future<void> _startMyIdSdk() async {
    if (_sessionId == null) {
      setState(() {
        _errorMessage = 'Session ID mavjud emas';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _currentStep = 2;
      _statusMessage = 'MyID SDK ishga tushirilmoqda...';
    });

    try {
      if (kDebugMode) {
        debugPrint('🔵 [2/4] MyID SDK ishga tushirish boshlandi');
        debugPrint('   Session ID: $_sessionId');
      }

      // Bosqich 3: Yuz tanish (3/4)
      setState(() {
        _currentStep = 3;
        _statusMessage = 'Yuz tanish jarayoni...';
      });

      // Saqlangan tilni yuklash
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('language') ?? 'uz';

      // Tilga mos MyIdLocale tanlash
      MyIdLocale locale;
      switch (savedLanguage) {
        case 'ru':
          locale = MyIdLocale.RUSSIAN;
          break;
        case 'en':
          locale = MyIdLocale.ENGLISH;
          break;
        default:
          locale = MyIdLocale.UZBEK;
      }

      if (kDebugMode) {
        debugPrint('   Tanlangan til: $savedLanguage -> $locale');
      }

      // MyID SDK'ni ishga tushirish
      final result = await MyIdClient.start(
        config: MyIdConfig(
          sessionId: _sessionId!,
          clientHash: '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5wQYaS8i1b0Rj5wuJLhI
yDuTW/WoWB/kRbJCBHFLyFTxETADNa/CU+xw0moN9X10+MVD5kRMinMRQpGUVCrU
XjUAEjwbdaCSLR6suRYI1EfDMQ5XFdJsfkAlNzZyyfBlif4OA4qxaMtdyvJCa/8n
wHn2KC89BNhqBQMre7iLaW8Z9bArSulSxBJzbzPjd7Jkg4ccQ47bVyjEKBcu/1KX
Ud/audUr1WsUpBf9yvgSTDRG2cuVXpMGEBJAqrsCS3RtIt7pEnGtr5FsB+UmBec9
Ei97fK2LcVfWpc/m7WjWMz3mku/pmhSjC6Vl6dlOrP1dv/fJkhfh3axzXtZoxgV1
QwIDAQAB
-----END PUBLIC KEY-----''',
          clientHashId: 'ac6d0f4a-5d5b-44e3-a865-9159a3146a8c',
          environment: MyIdEnvironment.DEBUG, // DEV muhiti
          entryType: MyIdEntryType.IDENTIFICATION,
          residency: MyIdResidency.USER_DEFINED,
          locale: locale, // Foydalanuvchi tanlagan til
        ),
        iosAppearance: const MyIdIOSAppearance(),
      );

      if (kDebugMode) {
        debugPrint('✅ [3/4] MyID SDK natija olindi');
        debugPrint('   Code (PINFL): ${result.code}');
      }

      // Natijani qayta ishlash
      await _handleMyIdResult(result);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 [2/4] MyID SDK xatosi: $e');
      }
      setState(() {
        _errorMessage = 'MyID SDK xatosi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Bosqich 4: MyID natijasini qayta ishlash va saqlash (4/4)
  ///
  /// SDK natijalarini qayta ishlash:
  /// - code="0": Muvaffaqiyatli (PINFL olindi)
  /// - code="1": Bekor qilindi
  /// - code="2" yoki "3": Xato
  ///
  /// Requirements: 3.6, 3.7, 3.8
  Future<void> _handleMyIdResult(MyIdResult result) async {
    setState(() {
      _currentStep = 4;
      _statusMessage = 'Ma\'lumotlar saqlanmoqda...';
    });

    try {
      if (kDebugMode) {
        debugPrint('🔵 [4/4] MyID natijasini qayta ishlash');
        debugPrint('   result.code: ${result.code}');
        debugPrint(
          '   result.base64: ${result.base64 != null ? "Mavjud" : "Yo'q"}',
        );
      }

      // MyID SDK code'larini tekshirish
      // Eslatma: MyID SDK Flutter versiyasida code PINFL ni qaytaradi
      // Lekin biz xato holatlarini ham tekshirishimiz kerak

      // Xato - code null yoki bo'sh (foydalanuvchi bekor qilgan - code="1")
      if (result.code == null || result.code!.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ [4/4] Foydalanuvchi jarayonni bekor qildi (code="1")');
        }
        setState(() {
          _errorMessage = 'Jarayon bekor qilindi. Qayta urinib ko\'ring.';
          _isLoading = false;
        });
        return;
      }

      // Xato - code "2" yoki "3" (SDK xatosi)
      if (result.code == '2' || result.code == '3') {
        if (kDebugMode) {
          debugPrint('🔴 [4/4] SDK xatosi (code="${result.code}")');
        }
        setState(() {
          _errorMessage = 'Identifikatsiya xatosi. Qayta urinib ko\'ring.';
          _isLoading = false;
        });
        return;
      }

      // Muvaffaqiyatli - code="0" yoki PINFL (14 raqam)
      if (kDebugMode) {
        debugPrint('✅ [4/4] Muvaffaqiyatli - PINFL olindi: ${result.code}');
      }

      // Muvaffaqiyatli natija - PINFL (code) olindi
      final userData = {
        'pinfl': result.code!,
        'full_name': 'MyID User',
        'verified': true,
        'timestamp': DateTime.now().toIso8601String(),
        'myid_code': result.code,
        'has_photo': result.base64 != null,
      };

      // SharedPreferences'ga saqlash
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(userData));

      if (kDebugMode) {
        debugPrint('✅ [4/4] Foydalanuvchi ma\'lumotlari saqlandi');
      }

      // Muvaffaqiyat xabarini ko'rsatish
      setState(() {
        _isLoading = false;
        _statusMessage = 'Muvaffaqiyatli!';
      });

      // 2 soniya kutish va home ekraniga o'tish
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 [4/4] Ma\'lumotlarni saqlashda xato: $e');
      }
      setState(() {
        _errorMessage = 'Ma\'lumotlarni saqlashda xato: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Qayta urinish
  void _retry() {
    setState(() {
      _currentStep = 1;
      _errorMessage = null;
      _sessionId = null;
    });
    _startFlow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _isLoading
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2E1A)),
                onPressed: () => Navigator.pop(context),
              ),
        title: const Text(
          'MyID Kirish',
          style: TextStyle(
            color: Color(0xFF1A2E1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_isLoading || _currentStep <= 4) {
      return _buildProgressView();
    }

    return const Center(child: Text('Kutilmagan holat'));
  }

  /// Jarayon ko'rinishi (loading + bosqichlar)
  Widget _buildProgressView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // MyID logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF0066cc).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066cc),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text(
                      'ID',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Bosqich ko'rsatkichi
            Text(
              'Bosqich $_currentStep/4',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2E1A),
              ),
            ),
            const SizedBox(height: 12),

            // Holat xabari
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Progress bar
            SizedBox(
              width: double.infinity,
              child: LinearProgressIndicator(
                value: _currentStep / 4,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF0066cc),
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 32),

            // Bosqichlar ro'yxati
            _buildStepsList(),

            const SizedBox(height: 32),

            // Loading indikator
            if (_isLoading)
              const CircularProgressIndicator(color: Color(0xFF0066cc)),
          ],
        ),
      ),
    );
  }

  /// Bosqichlar ro'yxati
  Widget _buildStepsList() {
    final steps = [
      {'number': 1, 'title': 'Sessiya yaratish'},
      {'number': 2, 'title': 'SDK ishga tushirish'},
      {'number': 3, 'title': 'Yuz tanish'},
      {'number': 4, 'title': 'Ma\'lumotlarni saqlash'},
    ];

    return Column(
      children: steps.map((step) {
        final stepNumber = step['number'] as int;
        final stepTitle = step['title'] as String;
        final isCompleted = stepNumber < _currentStep;
        final isCurrent = stepNumber == _currentStep;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // Step icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF15803D)
                      : isCurrent
                      ? const Color(0xFF0066cc)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                          '$stepNumber',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Step title
              Expanded(
                child: Text(
                  stepTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    color: isCompleted || isCurrent
                        ? const Color(0xFF1A2E1A)
                        : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Xato ko'rinishi
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 24),

            // Error title
            Text(
              'Xatolik yuz berdi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),

            // Error message
            Text(
              _errorMessage ?? 'Noma\'lum xato',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Retry button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066cc),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Qayta urinish',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Back button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Orqaga qaytish',
                style: TextStyle(fontSize: 14, color: Color(0xFF0066cc)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
