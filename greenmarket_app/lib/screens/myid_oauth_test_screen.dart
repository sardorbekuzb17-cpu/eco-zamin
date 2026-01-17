import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/myid_backend_service.dart';
import '../config/myid_config.dart';

class MyIdOAuthTestScreen extends StatefulWidget {
  const MyIdOAuthTestScreen({super.key});

  @override
  State<MyIdOAuthTestScreen> createState() => _MyIdOAuthTestScreenState();
}

class _MyIdOAuthTestScreenState extends State<MyIdOAuthTestScreen> {
  bool _isLoading = false;
  String? _accessToken;
  String? _tokenType;
  int? _expiresIn;
  String? _errorMessage;

  // Sessiya yaratish uchun
  bool _isCreatingSession = false;
  String? _sessionId;
  String? _sessionError;

  Future<void> _getAccessToken() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _accessToken = null;
    });

    try {
      final result = await MyIdBackendService.getAccessToken(
        clientId: MyIDConfig.clientId,
        clientSecret: MyIDConfig.clientSecret,
      );

      if (result['success'] == true) {
        setState(() {
          _accessToken = result['access_token'];
          _tokenType = result['token_type'];
          _expiresIn = result['expires_in'];
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Noma\'lum xatolik';
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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nusxalandi!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _createSession() async {
    if (_accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avval access token oling!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingSession = true;
      _sessionError = null;
      _sessionId = null;
    });

    try {
      final result = await MyIdBackendService.createSession(
        accessToken: _accessToken!,
        // Test uchun bo'sh parametrlar
        // Kerak bo'lsa qo'shish mumkin:
        // phoneNumber: '998901234567',
        // birthDate: '1990-01-01',
        // isResident: true,
      );

      if (result['success'] == true) {
        setState(() {
          _sessionId = result['session_id'];
        });
      } else {
        setState(() {
          _sessionError = result['error'] ?? 'Noma\'lum xatolik';
        });
      }
    } catch (e) {
      setState(() {
        _sessionError = 'Xatolik: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isCreatingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('MyID OAuth Test'),
        backgroundColor: const Color(0xFF15803D),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ma'lumot kartasi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'API Test',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu ekranda MyID OAuth API dan access token olish jarayonini test qilishingiz mumkin.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Client ID va Secret
              _buildInfoCard('Client ID', MyIDConfig.clientId, Icons.vpn_key),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Client Secret',
                '${MyIDConfig.clientSecret.substring(0, 20)}...',
                Icons.lock,
              ),
              const SizedBox(height: 24),

              // Access Token olish tugmasi
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _getAccessToken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066cc),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.token),
                            SizedBox(width: 12),
                            Text(
                              'Access Token Olish',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Natija
              if (_accessToken != null) ...[
                const SizedBox(height: 24),
                _buildSuccessCard(),

                // Sessiya yaratish tugmasi
                const SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isCreatingSession ? null : _createSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15803D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isCreatingSession
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline),
                              SizedBox(width: 12),
                              Text(
                                'Sessiya Yaratish',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],

              // Sessiya natijasi
              if (_sessionId != null) ...[
                const SizedBox(height: 24),
                _buildSessionSuccessCard(),
              ],

              // Sessiya xatosi
              if (_sessionError != null) ...[
                const SizedBox(height: 24),
                _buildSessionErrorCard(),
              ],

              // Xatolik
              if (_errorMessage != null) ...[
                const SizedBox(height: 24),
                _buildErrorCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Muvaffaqiyatli!',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResultRow('Token Type', _tokenType ?? 'N/A'),
          const SizedBox(height: 8),
          _buildResultRow(
            'Expires In',
            '${_expiresIn ?? 0} soniya (${(_expiresIn ?? 0) ~/ 3600} soat / ${(_expiresIn ?? 0) ~/ 86400} kun)',
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Access Token:',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _accessToken ?? '',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyToClipboard(_accessToken ?? ''),
                  color: Colors.green[700],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.green[900])),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xatolik',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_errorMessage!, style: TextStyle(color: Colors.red[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Sessiya yaratildi!',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Session ID:',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _sessionId ?? '',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyToClipboard(_sessionId ?? ''),
                  color: Colors.green[700],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionErrorCard() {
    return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sessiya yaratishda xatolik',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_sessionError!, style: TextStyle(color: Colors.red[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
