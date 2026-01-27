import 'package:flutter/material.dart';
import '../services/myid_oauth_service.dart';

/// MyID Kirish Ekrani - Passport ma'lumotlari bilan
class MyIdCompleteTestScreen extends StatefulWidget {
  const MyIdCompleteTestScreen({super.key});

  @override
  State<MyIdCompleteTestScreen> createState() => _MyIdCompleteTestScreenState();
}

class _MyIdCompleteTestScreenState extends State<MyIdCompleteTestScreen> {
  bool _isLoading = false;
  String? _statusMessage;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  // Passport ma'lumotlari
  final _passportSeriesController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _birthDateController = TextEditingController();

  @override
  void dispose() {
    _passportSeriesController.dispose();
    _passportNumberController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _startMyIdFlow() async {
    final passportSeries = _passportSeriesController.text.trim();
    final passportNumber = _passportNumberController.text.trim();
    final birthDate = _birthDateController.text.trim();

    if (passportSeries.isEmpty || passportNumber.isEmpty || birthDate.isEmpty) {
      setState(() {
        _errorMessage = 'Barcha maydonlarni to\'ldiring';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _userData = null;
      _statusMessage = 'Jarayon boshlanmoqda...';
    });

    try {
      final result =
          await MyIdOAuthService.completeAuthFlow(
            passportSeries: passportSeries,
            passportNumber: passportNumber,
            birthDate: birthDate,
            onStatusUpdate: (status) {
              setState(() => _statusMessage = status);
            },
          ).timeout(
            const Duration(seconds: 60),
            onTimeout: () => {
              'success': false,
              'error': 'Timeout: Jarayon ko\'p vaqt oldi',
            },
          );

      if (result['success'] == true) {
        setState(() {
          _userData = result;
          _isLoading = false;
          _statusMessage = 'Muvaffaqiyatli yakunlandi!';
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Noma\'lum xato';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Xato: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MyID Kirish'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  color: Colors.red[50],
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xato:',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_statusMessage != null && _isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (_userData != null)
                Container(
                  width: double.infinity,
                  color: Colors.green[50],
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Muvaffaqiyatli kirish!',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDataRow('Session ID:', _userData!['session_id']),
                      _buildDataRow(
                        'Full Name:',
                        '${_userData!['profile']['first_name']} ${_userData!['profile']['last_name']}',
                      ),
                      _buildDataRow(
                        'Comparison:',
                        '${_userData!['comparison_value']}',
                      ),
                      _buildDataRow('ReUID:', '${_userData!['reuid']}'),
                    ],
                  ),
                ),
              if (!_isLoading) ...[
                TextField(
                  controller: _passportSeriesController,
                  decoration: InputDecoration(
                    labelText: 'Pasport seriyasi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.credit_card),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passportNumberController,
                  decoration: InputDecoration(
                    labelText: 'Pasport raqami',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.numbers),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _birthDateController,
                  decoration: InputDecoration(
                    labelText: 'Tug\'ilgan sana (YYYY-MM-DD)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: CircularProgressIndicator(color: Color(0xFF15803D)),
                ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _startMyIdFlow,
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    'MyID orqali kirish',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF1A5D1A),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
