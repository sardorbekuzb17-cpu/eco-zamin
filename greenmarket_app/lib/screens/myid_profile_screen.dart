import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/myid_profile_model.dart';
import '../services/myid_oauth_service.dart';
import '../services/myid_error_handler.dart';

class MyIdProfileScreen extends StatefulWidget {
  const MyIdProfileScreen({super.key});

  @override
  State<MyIdProfileScreen> createState() => _MyIdProfileScreenState();
}

class _MyIdProfileScreenState extends State<MyIdProfileScreen> {
  MyIdProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  String? _accessToken;
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileData = prefs.getString('myid_profile');
      _accessToken = prefs.getString('myid_access_token');
      _sessionId = prefs.getString('myid_session_id');

      if (profileData != null) {
        final profileJson = json.decode(profileData);
        setState(() {
          _profile = MyIdProfileModel.fromJson(profileJson);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Profil ma\'lumotlari topilmadi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ma\'lumotlarni yuklashda xatolik: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProfile() async {
    if (_accessToken == null || _sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token yoki sessiya topilmadi')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Avval sessiyani tiklash
      final restoreResult = await MyIdOAuthService.restoreSession(
        accessToken: _accessToken!,
        sessionId: _sessionId!,
      );

      if (restoreResult['success'] == true) {
        // Keyin profil ma'lumotlarini olish
        final profileResult = await MyIdOAuthService.getUserProfile(
          accessToken: _accessToken!,
          sessionId: _sessionId!,
        );

        if (profileResult['success'] == true) {
          // Yangi ma'lumotlarni saqlash
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'myid_profile',
            json.encode(profileResult['profile']),
          );

          setState(() {
            _profile = MyIdProfileModel.fromJson(profileResult['profile']);
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Profil yangilandi')));
          }
        } else {
          setState(() {
            _errorMessage = profileResult['error'];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = restoreResult['error'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Yangilashda xatolik: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('myid_profile');
      await prefs.remove('myid_access_token');
      await prefs.remove('myid_session_id');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xatolik: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyID Profil'),
        centerTitle: true,
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
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar va ism
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Status
                    if (_profile?.status != null) _buildStatusCard(),
                    if (_profile?.status != null) const SizedBox(height: 16),

                    // Asosiy ma'lumotlar
                    if (_profile?.commonData != null) _buildCommonDataCard(),
                    if (_profile?.commonData != null)
                      const SizedBox(height: 16),

                    // Aloqa ma'lumotlari
                    if (_profile?.persData != null) _buildContactCard(),
                    if (_profile?.persData != null) const SizedBox(height: 16),

                    // Manzil
                    if (_profile?.persData?.permanentRegistration != null)
                      _buildAddressCard(),
                    if (_profile?.persData?.permanentRegistration != null)
                      const SizedBox(height: 16),

                    // Hujjat ma'lumotlari
                    if (_profile?.issuedBy != null) _buildDocumentCard(),
                    if (_profile?.issuedBy != null) const SizedBox(height: 16),

                    // Yangilash tugmasi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _refreshProfile,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Profilni yangilash'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15803D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final firstName = _profile?.commonData?.firstName ?? '';
    final lastName = _profile?.commonData?.lastName ?? '';
    final middleName = _profile?.commonData?.middleName ?? '';
    final fullName = '$lastName $firstName $middleName'.trim();

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF15803D),
            child: Text(
              firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName.isNotEmpty ? fullName : 'Foydalanuvchi',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (_profile?.commonData?.pinfl != null) ...[
            const SizedBox(height: 4),
            Text(
              'PINFL: ${_profile!.commonData!.pinfl}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final code = _profile?.code ?? '';
    final status = _profile?.status ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  code == '0' ? Icons.check_circle : Icons.info_outline,
                  color: code == '0' ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            if (_profile?.code != null) ...[
              _buildInfoRow('Kod:', _profile!.code!),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: code == '0' ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: code == '0'
                        ? Colors.green[200]!
                        : Colors.orange[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MyIdErrorHandler.getErrorMessage(code),
                      style: TextStyle(
                        color: code == '0'
                            ? Colors.green[900]
                            : Colors.orange[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (code != '0') ...[
                      const SizedBox(height: 8),
                      Text(
                        MyIdErrorHandler.getErrorSuggestion(code),
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (_profile?.status != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Holat:',
                MyIdErrorHandler.getSessionStatusMessage(status),
              ),
            ],
            if (_profile?.timestamp != null)
              _buildInfoRow('Vaqt:', _profile!.timestamp!),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonDataCard() {
    final data = _profile!.commonData!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asosiy ma\'lumotlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            if (data.firstName != null) _buildInfoRow('Ism:', data.firstName!),
            if (data.lastName != null)
              _buildInfoRow('Familiya:', data.lastName!),
            if (data.middleName != null)
              _buildInfoRow('Otasining ismi:', data.middleName!),
            if (data.pinfl != null) _buildInfoRow('PINFL:', data.pinfl!),
            if (data.gender != null) _buildInfoRow('Jins:', data.gender!),
            if (data.birthDate != null)
              _buildInfoRow('Tug\'ilgan sana:', data.birthDate!),
            if (data.birthPlace != null)
              _buildInfoRow('Tug\'ilgan joy:', data.birthPlace!),
            if (data.nationality != null)
              _buildInfoRow('Millati:', data.nationality!),
            if (data.citizenship != null)
              _buildInfoRow('Fuqaroligi:', data.citizenship!),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    final data = _profile!.persData!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aloqa ma\'lumotlari',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            if (data.phone != null) _buildInfoRow('Telefon:', data.phone!),
            if (data.email != null) _buildInfoRow('Email:', data.email!),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    final reg = _profile!.persData!.permanentRegistration!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Doimiy ro\'yxatdan o\'tgan manzil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            if (reg.region != null) _buildInfoRow('Viloyat:', reg.region!),
            if (reg.district != null) _buildInfoRow('Tuman:', reg.district!),
            if (reg.mfy != null) _buildInfoRow('MFY:', reg.mfy!),
            if (reg.address != null) _buildInfoRow('Manzil:', reg.address!),
            if (reg.cadstre != null) _buildInfoRow('Kadastr:', reg.cadstre!),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard() {
    final doc = _profile!.issuedBy!;
    final docTypeId = doc.docTypeId ?? _profile?.commonData?.docTypeId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hujjat ma\'lumotlari',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            if (docTypeId != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.badge, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        MyIdErrorHandler.getDocumentTypeName(docTypeId),
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (doc.docType != null)
              _buildInfoRow('Hujjat turi:', doc.docType!),
            if (doc.issuedBy != null)
              _buildInfoRow('Kim tomonidan berilgan:', doc.issuedBy!),
            if (doc.issuedDate != null)
              _buildInfoRow('Berilgan sana:', doc.issuedDate!),
            if (doc.expiryDate != null)
              _buildInfoRow('Amal qilish muddati:', doc.expiryDate!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
