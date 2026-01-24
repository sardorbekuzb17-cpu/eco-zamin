import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/myid_oauth_service.dart';

/// MyID SDK Flow ekrani (ilova ichida)
///
/// To'liq oqim:
/// 1) Access token olish
/// 2) Session yaratish
/// 3) MyID SDK (pasport + face)
/// 4) Profil ma'lumotlarini olish va saqlash
class MyIdSdkFlowScreen extends StatefulWidget {
  const MyIdSdkFlowScreen({super.key});

  @override
  State<MyIdSdkFlowScreen> createState() => _MyIdSdkFlowScreenState();
}

class _MyIdSdkFlowScreenState extends State<MyIdSdkFlowScreen> {
  int _currentStep = 1; // 1-4
  bool _isLoading = true;
  String? _errorMessage;
  String _statusMessage = 'Jarayon boshlanmoqda...';

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  int _stepFromStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('access token')) return 1;
    if (s.contains('sessiya') || s.contains('session')) return 2;
    if (s.contains('sdk')) return 3;
    if (s.contains("foydalanuvchi") ||
        s.contains("profil") ||
        s.contains("ma'lumot")) {
      return 4;
    }
    return _currentStep;
  }

  Future<void> _startFlow() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentStep = 1;
      _statusMessage = 'Access token olinmoqda...';
    });

    try {
      final result = await MyIdOAuthService.completeAuthFlow(
        onStatusUpdate: (status) {
          if (!mounted) return;
          setState(() {
            _statusMessage = status;
            _currentStep = _stepFromStatus(status);
          });
        },
      );

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        // To'liq profil ma'lumotlarini saqlash
        await prefs.setString('myid_profile', json.encode(result['profile']));
        await prefs.setString('myid_access_token', result['access_token']);
        await prefs.setString('myid_session_id', result['session_id']);

        final userData = {
          'session_id': result['session_id'],
          'profile': result['profile'],
          'data': result['data'],
          'comparison_value': result['comparison_value'],
          'pers_data': result['pers_data'],
          'pin_id': result['pin_id'],
          'timestamp': DateTime.now().toIso8601String(),
          'verified': true,
          'auth_method': 'sdk_flow',
        };
        await prefs.setString('user_data', json.encode(userData));

        setState(() {
          _isLoading = false;
          _currentStep = 4;
          _statusMessage = 'Muvaffaqiyatli!';
        });

        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
        return;
      }

      setState(() {
        _errorMessage = result['error'] ?? 'Noma\'lum xatolik';
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MyID flow error: $e');
      }
      setState(() {
        _errorMessage = 'Xatolik: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _retry() {
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

    return _buildProgressView();
  }

  Widget _buildProgressView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Text(
              'Bosqich $_currentStep/4',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2E1A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
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
            const SizedBox(height: 24),
            _buildStepsList(),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator(color: Color(0xFF0066cc)),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsList() {
    final steps = [
      {'number': 1, 'title': 'Access token olish'},
      {'number': 2, 'title': 'Sessiya yaratish'},
      {'number': 3, 'title': 'MyID SDK (pasport + yuz tanish)'},
      {'number': 4, 'title': 'Profilni olish va saqlash'},
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

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Text(
              'Xatolik yuz berdi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Noma\'lum xato',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
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
