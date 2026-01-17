import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/myid_profile_model.dart';
import 'myid_main_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MyIdProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileData = prefs.getString('myid_profile');

      if (profileData != null) {
        final profileJson = json.decode(profileData);
        setState(() {
          _profile = MyIdProfileModel.fromJson(profileJson);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('myid_profile');
    await prefs.remove('myid_access_token');
    await prefs.remove('myid_session_id');
    await prefs.remove('user_data');

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyIdMainLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GreenMarket'),
        backgroundColor: const Color(0xFF2ecc71),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Chiqish',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foydalanuvchi ma'lumotlari
                  if (_profile != null) ...[
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: const Color(0xFF2ecc71),
                                  child: Text(
                                    _profile!.commonData?.firstName?[0]
                                            .toUpperCase() ??
                                        'U',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_profile!.commonData?.lastName ?? ''} ${_profile!.commonData?.firstName ?? ''}'
                                            .trim(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (_profile!.commonData?.pinfl != null)
                                        Text(
                                          'JSHSHIR: ${_profile!.commonData!.pinfl}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      if (_profile!.status != null)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _profile!.code == '0'
                                                ? Colors.green[100]
                                                : Colors.orange[100],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            _profile!.code == '0'
                                                ? '✓ Tasdiqlangan'
                                                : '⚠ Tekshirilmoqda',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: _profile!.code == '0'
                                                  ? Colors.green[900]
                                                  : Colors.orange[900],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24, thickness: 1),
                            if (_profile!.commonData?.birthDate != null)
                              _buildInfoRow(
                                Icons.cake,
                                'Tug\'ilgan sana',
                                _profile!.commonData!.birthDate!,
                              ),
                            if (_profile!.commonData?.gender != null)
                              _buildInfoRow(
                                Icons.person,
                                'Jins',
                                _profile!.commonData!.gender!,
                              ),
                            if (_profile!.persData?.phone != null)
                              _buildInfoRow(
                                Icons.phone,
                                'Telefon',
                                _profile!.persData!.phone!,
                              ),
                            if (_profile!.persData?.email != null)
                              _buildInfoRow(
                                Icons.email,
                                'Email',
                                _profile!.persData!.email!,
                              ),
                            if (_profile!
                                    .persData
                                    ?.permanentRegistration
                                    ?.region !=
                                null)
                              _buildInfoRow(
                                Icons.location_on,
                                'Manzil',
                                '${_profile!.persData!.permanentRegistration!.region}, ${_profile!.persData!.permanentRegistration!.district ?? ''}',
                              ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/profile');
                                },
                                icon: const Icon(Icons.person),
                                label: const Text('To\'liq profil'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2ecc71),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Asosiy funksiyalar
                  const Text(
                    'Asosiy bo\'limlar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.badge,
                        title: 'Pasport Input',
                        color: const Color(0xFFe74c3c),
                        onTap: () {
                          Navigator.pushNamed(context, '/passport-input');
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.cloud,
                        title: 'Backend Login',
                        color: const Color(0xFF3498db),
                        onTap: () {
                          Navigator.pushNamed(context, '/backend-login');
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.verified_user,
                        title: 'To\'liq OAuth',
                        color: const Color(0xFF2ecc71),
                        onTap: () {
                          Navigator.pushNamed(context, '/complete-login');
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.admin_panel_settings,
                        title: 'Admin Panel',
                        color: const Color(0xFFf39c12),
                        onTap: () {
                          Navigator.pushNamed(context, '/admin-users');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2ecc71)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
