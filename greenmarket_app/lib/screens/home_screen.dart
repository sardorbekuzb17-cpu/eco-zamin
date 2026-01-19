import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/myid_user_service.dart';
import 'myid_main_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Yangi formatdan o'qish
      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null) {
        setState(() {
          _userData = json.decode(userDataStr);
          _isLoading = false;
        });
        return;
      }

      // Eski formatdan o'qish (compatibility)
      final profileData = prefs.getString('myid_profile');
      if (profileData != null) {
        final profileJson = json.decode(profileData);
        setState(() {
          _userData = {
            'pinfl': profileJson['commonData']?['pinfl'],
            'profile': profileJson,
            'verified': true,
            'auth_method': 'legacy',
          };
          _isLoading = false;
        });
        return;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Barcha ma'lumotlarni o'chirish
    await prefs.remove('user_data');
    await prefs.remove('myid_profile');
    await prefs.remove('myid_access_token');
    await prefs.remove('myid_session_id');

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
          : _userData == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Foydalanuvchi ma\'lumotlari topilmadi',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const MyIdMainLoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Qayta kirish'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foydalanuvchi ma'lumotlari
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
                                  (_userData!['pinfl'] as String?)
                                          ?.substring(0, 1)
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userData!['pinfl'] ?? 'Noma\'lum',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'JSHSHIR: ${_userData!['pinfl'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (_userData!['verified'] == true)
                                            ? Colors.green[100]
                                            : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        (_userData!['verified'] == true)
                                            ? '✓ Tasdiqlangan'
                                            : '⚠ Tekshirilmoqda',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              (_userData!['verified'] == true)
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
                          _buildInfoRow(
                            Icons.verified_user,
                            'Autentifikatsiya usuli',
                            (_userData!['auth_method'] as String?)
                                    ?.replaceAll('_', ' ')
                                    .toUpperCase() ??
                                'N/A',
                          ),
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Kirish vaqti',
                            _formatDateTime(_userData!['timestamp'] as String?),
                          ),
                          if (_userData!['profile'] != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _showProfileDetails();
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
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _refreshUserData,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Yangilash'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3498db),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

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
                      _buildFeatureCard(
                        icon: Icons.science,
                        title: 'SDK Test',
                        color: const Color(0xFF9b59b6),
                        onTap: () {
                          Navigator.pushNamed(context, '/simple-test');
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.account_tree,
                        title: 'Chizma bo\'yicha',
                        color: const Color(0xFF16a085),
                        onTap: () {
                          Navigator.pushNamed(context, '/diagram-flow');
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

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  void _showProfileDetails() {
    if (_userData?['profile'] == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('To\'liq profil ma\'lumotlari'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'JSON ma\'lumotlar:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  json.encode(_userData!['profile']).replaceAll(',', ',\n'),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshUserData() async {
    if (_userData?['pinfl'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINFL topilmadi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await MyIdUserService.getUserDataByCode(
        _userData!['pinfl'] as String,
      );

      if (result['success'] == true) {
        setState(() {
          _userData!['profile'] = result['data'];
          _userData!['timestamp'] = DateTime.now().toIso8601String();
          _isLoading = false;
        });

        // SharedPreferences'ga saqlash
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(_userData));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ma\'lumotlar yangilandi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xato: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xato: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
