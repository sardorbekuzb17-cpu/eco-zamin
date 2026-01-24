import 'package:flutter/material.dart';
import '../services/myid_table_requests.dart';
import 'myid_successful_login_screen.dart';

/// MyID Kirish Ekrani
class MyIdCompleteTestScreen extends StatefulWidget {
  const MyIdCompleteTestScreen({super.key});

  @override
  State<MyIdCompleteTestScreen> createState() => _MyIdCompleteTestScreenState();
}

class _MyIdCompleteTestScreenState extends State<MyIdCompleteTestScreen> {
  String _status = 'Tayyor';
  bool _isLoading = false;
  final List<String> _logs = [];
  String? _errorMessage;

  // Credentials
  final String _clientId =
      'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
  final String _clientSecret =
      'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().split('.')[0]} - $message');
    });
    debugPrint(message);
  }

  Future<void> _testAllTables() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _logs.clear();
      _status = 'Jarayonda...';
    });

    try {
      // 1-JADVAL: Access Token Olish
      _addLog('📤 1-JADVAL: Access token olinmoqda...');
      setState(() => _status = '1-JADVAL: Access token olinmoqda...');

      final table1Result = await MyIdTableRequests.table1GetAccessToken(
        clientId: _clientId,
        clientSecret: _clientSecret,
      );

      if (!table1Result['success']) {
        _addLog('❌ 1-JADVAL XATOSI: ${table1Result['error']}');
        setState(() {
          _errorMessage = table1Result['error'];
          _status = 'Xato: 1-jadval';
          _isLoading = false;
        });
        return;
      }

      final accessToken1 = table1Result['access_token'];
      _addLog('✅ 1-JADVAL: Access token olindi');
      _addLog('   Token uzunligi: ${accessToken1.length}');

      // 2-JADVAL: Session Yaratish
      _addLog('📤 2-JADVAL: Session yaratilmoqda...');
      setState(() => _status = '2-JADVAL: Session yaratilmoqda...');

      final table2Result = await MyIdTableRequests.table2CreateSession(
        accessToken: accessToken1,
      );

      if (!table2Result['success']) {
        _addLog('❌ 2-JADVAL XATOSI: ${table2Result['error']}');
        if (table2Result['validation_errors'] != null) {
          for (final error in table2Result['validation_errors']) {
            _addLog('   - $error');
          }
        }
        setState(() {
          _errorMessage = table2Result['error'];
          _status = 'Xato: 2-jadval';
          _isLoading = false;
        });
        return;
      }

      final sessionId = table2Result['session_id'];
      final accessToken2 = table2Result['access_token'];
      _addLog('✅ 2-JADVAL: Session yaratildi');
      _addLog('   Session ID: $sessionId');
      _addLog('   Access token uzunligi: ${accessToken2.length}');

      // SDK ni ishga tushirish uchun eslatma
      _addLog('⚠️  SDK ni ishga tushirish uchun session_id dan foydalaning');
      _addLog('   Session ID: $sessionId');

      // Test uchun dummy code ishlatamiz
      // Haqiqiy ilovada SDK'dan code olish kerak
      const dummyCode = 'test_code_12345';
      _addLog('📝 Test uchun dummy code ishlatilmoqda: $dummyCode');

      // 3-JADVAL: Foydalanuvchi Ma'lumotlarini Olish
      _addLog('📤 3-JADVAL: Foydalanuvchi ma\'lumotlari olinmoqda...');
      setState(
        () => _status = '3-JADVAL: Foydalanuvchi ma\'lumotlari olinmoqda...',
      );

      final table3Result = await MyIdTableRequests.table3GetUserData(
        code: dummyCode,
        accessToken: accessToken2,
      );

      if (!table3Result['success']) {
        _addLog('❌ 3-JADVAL XATOSI: ${table3Result['error']}');
        if (table3Result['validation_errors'] != null) {
          for (final error in table3Result['validation_errors']) {
            _addLog('   - $error');
          }
        }
        setState(() {
          _errorMessage = table3Result['error'];
          _status = 'Xato: 3-jadval';
          _isLoading = false;
        });
        return;
      }

      final profile = table3Result['profile'];
      _addLog('✅ 3-JADVAL: Foydalanuvchi ma\'lumotlari olindi');
      _addLog('   PINFL: ${profile['pinfl']}');
      _addLog('   Ism: ${profile['name']}');
      _addLog('   Familiya: ${profile['surname']}');

      // Muvaffaqiyat
      _addLog('✅ BARCHA JADVALLAR MUVAFFAQIYATLI BAJARILDI!');
      setState(() {
        _status = 'Muvaffaqiyatli!';
        _isLoading = false;
      });

      // Muvaffaqiyatli kirish ekraniga o'tish
      if (mounted) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyIdSuccessfulLoginScreen(
                userData: profile,
                accessToken: accessToken2,
                sessionId: sessionId,
              ),
            ),
          );
        }
      }
    } catch (e) {
      _addLog('❌ XATOLIK: $e');
      setState(() {
        _errorMessage = e.toString();
        _status = 'Xato';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MyID Kirish'), centerTitle: true),
      body: Column(
        children: [
          // Status kartasi
          Container(
            color: _isLoading
                ? Colors.blue[50]
                : _errorMessage != null
                ? Colors.red[50]
                : Colors.green[50],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (_errorMessage != null)
                      Icon(Icons.error, color: Colors.red[700], size: 24)
                    else
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 24,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _status,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isLoading
                              ? Colors.blue[900]
                              : _errorMessage != null
                              ? Colors.red[900]
                              : Colors.green[900],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 13, color: Colors.red[700]),
                  ),
                ],
              ],
            ),
          ),

          // Loglar
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final isError = log.contains('❌');
                final isSuccess = log.contains('✅');
                final isInfo =
                    log.contains('📤') ||
                    log.contains('📝') ||
                    log.contains('⚠️');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    log,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: isError
                          ? Colors.red[700]
                          : isSuccess
                          ? Colors.green[700]
                          : isInfo
                          ? Colors.blue[700]
                          : Colors.grey[700],
                    ),
                  ),
                );
              },
            ),
          ),

          // Tugma
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testAllTables,
                  icon: const Icon(Icons.login),
                  label: const Text('MyID'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
