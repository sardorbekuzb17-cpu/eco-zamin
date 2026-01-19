import 'package:flutter/material.dart';
import '../services/myid_backend_client.dart';

class MyIdSimpleTestScreen extends StatefulWidget {
  const MyIdSimpleTestScreen({super.key});

  @override
  State<MyIdSimpleTestScreen> createState() => _MyIdSimpleTestScreenState();
}

class _MyIdSimpleTestScreenState extends State<MyIdSimpleTestScreen> {
  String? _result;
  bool _isLoading = false;

  Future<void> _testSDK() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      // 1. Backend'dan sessiya olish
      final sessionResult = await MyIdBackendClient.getSession();

      if (sessionResult['success'] != true) {
        setState(() {
          _result = 'Sessiya olishda xatolik: ${sessionResult['error']}';
        });
        return;
      }

      final sessionId = sessionResult['data']['session_id'];

      // 2. SDK'ni ishga tushirish
      final result = await MyIdBackendClient.startSDK(sessionId: sessionId);

      setState(() {
        _result =
            '''
Muvaffaqiyatli!

Session ID: $sessionId
Code: ${result['code']}

SDK to'g'ri ishladi!
''';
      });
    } catch (e) {
      setState(() {
        _result = 'Xatolik: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('MyID SDK Test'),
        backgroundColor: const Color(0xFF15803D),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'SDK Test (Dokumentatsiyaga muvofiq)',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bu test SDK\'ni to\'g\'ri parametrlar bilan ishga tushiradi.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _testSDK,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066cc),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                      : const Text(
                          'SDK\'ni test qilish',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              if (_result != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _result!.contains('Xatolik')
                        ? Colors.red[50]
                        : Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _result!.contains('Xatolik')
                          ? Colors.red[200]!
                          : Colors.green[200]!,
                    ),
                  ),
                  child: Text(
                    _result!,
                    style: TextStyle(
                      color: _result!.contains('Xatolik')
                          ? Colors.red[700]
                          : Colors.green[700],
                    ),
                  ),
                ),
              ],

              const Spacer(),

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
                        const SizedBox(width: 8),
                        Text(
                          'Test ma\'lumotlari',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Environment: DEBUG\n'
                      'Entry Type: IDENTIFICATION\n'
                      'Residency: USER_DEFINED\n'
                      'SessionId: Backend\'dan olinadi',
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
