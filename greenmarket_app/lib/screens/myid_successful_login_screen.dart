import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// MyID Muvaffaqiyatli Kirish Ekrani
///
/// Bu ekran foydalanuvchi muvaffaqiyatli kirgandan so'ng
/// olingan ma'lumotlarni ko'rsatadi
class MyIdSuccessfulLoginScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String accessToken;
  final String sessionId;

  const MyIdSuccessfulLoginScreen({
    super.key,
    required this.userData,
    required this.accessToken,
    required this.sessionId,
  });

  @override
  State<MyIdSuccessfulLoginScreen> createState() =>
      _MyIdSuccessfulLoginScreenState();
}

class _MyIdSuccessfulLoginScreenState extends State<MyIdSuccessfulLoginScreen> {
  @override
  void initState() {
    super.initState();
    _saveUserData();
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Foydalanuvchi ma'lumotlarini saqlash
      await prefs.setString('myid_user_data', json.encode(widget.userData));

      // Token'larni saqlash
      await prefs.setString('myid_access_token', widget.accessToken);
      await prefs.setString('myid_session_id', widget.sessionId);

      // Kirish vaqtini saqlash
      await prefs.setString(
        'myid_login_time',
        DateTime.now().toIso8601String(),
      );

      // Kirish holati
      await prefs.setBool('myid_is_logged_in', true);
    } catch (e) {
      debugPrint('Ma\'lumotlarni saqlashda xato: $e');
    }
  }

  Future<void> _goToProfile() async {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  Future<void> _goToHome() async {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.userData['profile'] ?? {};
    final pinfl = profile['pinfl'] ?? 'N/A';
    final name = profile['name'] ?? 'Foydalanuvchi';
    final surname = profile['surname'] ?? '';
    final birthDate = profile['birth_date'] ?? 'N/A';
    final gender = profile['gender'] ?? 'N/A';
    final phone = profile['phone'] ?? 'N/A';
    final email = profile['email'] ?? 'N/A';
    final passportNumber = profile['passport_number'] ?? 'N/A';
    final passportSeries = profile['passport_series'] ?? 'N/A';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Muvaffaqiyat belgisi
                const SizedBox(height: 32),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 24),

                // Muvaffaqiyat xabari
                Text(
                  'Muvaffaqiyatli Kirildi!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sizning ma\'lumotlaringiz muvaffaqiyatli olingan',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Profil kartasi
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar va ism
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFF15803D),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$surname $name',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'PINFL: $pinfl',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Asosiy ma'lumotlar
                        _buildInfoSection('Asosiy Ma\'lumotlar', [
                          _buildInfoItem('Tug\'ilgan sana', birthDate),
                          _buildInfoItem(
                            'Jinsiyati',
                            gender == 'M' ? 'Erkak' : 'Ayol',
                          ),
                          _buildInfoItem('PINFL', pinfl),
                        ]),
                        const SizedBox(height: 16),

                        // Aloqa ma'lumotlari
                        _buildInfoSection('Aloqa Ma\'lumotlari', [
                          _buildInfoItem('Telefon', phone),
                          _buildInfoItem('Email', email),
                        ]),
                        const SizedBox(height: 16),

                        // Pasport ma'lumotlari
                        _buildInfoSection('Pasport Ma\'lumotlari', [
                          _buildInfoItem(
                            'Pasport',
                            '$passportSeries$passportNumber',
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Tugmalar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15803D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Profilga O\'tish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _goToHome,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Bosh Sahifaga O\'tish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF15803D),
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
