import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/myid_service.dart';
import 'home_screen.dart';

class MyIDLoginScreen extends StatefulWidget {
  const MyIDLoginScreen({super.key});

  @override
  State<MyIDLoginScreen> createState() => _MyIDLoginScreenState();
}

class _MyIDLoginScreenState extends State<MyIDLoginScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // Foydalanuvchi allaqachon kirganmi tekshirish
  Future<void> _checkAuthentication() async {
    final isAuth = await MyIDService.isAuthenticated();
    if (isAuth && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // MyID orqali kirish
  Future<void> _loginWithMyID() async {
    setState(() => _isLoading = true);

    try {
      final authUrl = MyIDService.getAuthorizationUrl();
      final uri = Uri.parse(authUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Callback'ni kutish uchun listener qo'shish kerak
        // Bu yerda deep link orqali callback qaytadi
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('MyID ochilmadi')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // An'anaviy kirish
  Future<void> _traditionalLogin() async {
    // Bu yerda telefon/parol bilan kirish logikasi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'An\'anaviy kirish hozircha ishlamaydi. MyID dan foydalaning.',
        ),
      ),
    );
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
                      // Logo
                      const Text('🌱', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),

                      // Sarlavha
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

                      // MyID tugmasi
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

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'yoki',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Telefon input
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Telefon raqam',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 16),

                      // Parol input
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Parol',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                      ),

                      const SizedBox(height: 24),

                      // Kirish tugmasi
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _traditionalLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ecc71),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Kirish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Afzalliklar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MyID orqali kirish afzalliklari:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildBenefit('Tez va xavfsiz autentifikatsiya'),
                            _buildBenefit(
                              'Ma\'lumotlar avtomatik to\'ldiriladi',
                            ),
                            _buildBenefit('Parol eslab qolish shart emas'),
                            _buildBenefit('Davlat tomonidan tasdiqlangan'),
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

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2ecc71), size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
