import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/myid_backend_service.dart';
import '../config/myid_config.dart';

class MyIdSessionLoginScreen extends StatefulWidget {
  const MyIdSessionLoginScreen({super.key});

  @override
  State<MyIdSessionLoginScreen> createState() => _MyIdSessionLoginScreenState();
}

class _MyIdSessionLoginScreenState extends State<MyIdSessionLoginScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _sessionId;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  // 1. Session yaratish
  Future<void> _initializeSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Backend'dan session_id olish
      final result = await MyIdBackendService.createEmptySession();

      if (result['success'] == true) {
        final sessionId = result['data']['session_id'] as String?;

        if (sessionId != null) {
          setState(() {
            _sessionId = sessionId;
          });

          // WebView'ni sozlash
          await _setupWebView(sessionId);
        } else {
          setState(() {
            _errorMessage = 'Session ID topilmadi';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Session yaratishda xato';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Xatolik: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // 2. WebView sozlash
  Future<void> _setupWebView(String sessionId) async {
    try {
      // MyID login URL yaratish
      final loginUrl = Uri.parse('${MyIDConfig.baseUrl}/oauth/authorize')
          .replace(
            queryParameters: {
              'client_id': MyIDConfig.clientId,
              'response_type': 'one_code',
              'scope': MyIDConfig.scope,
              'redirect_uri': MyIDConfig.redirectUri,
              'state': sessionId, // Session ID ni state sifatida yuboramiz
            },
          );

      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) {
              // Callback URL'ni tekshirish
              if (request.url.startsWith(MyIDConfig.redirectUri)) {
                _handleCallback(request.url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onPageStarted: (url) {
              if (mounted) {
                setState(() => _isLoading = true);
              }
            },
            onPageFinished: (url) {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
            onWebResourceError: (error) {
              if (mounted) {
                setState(() {
                  _errorMessage = 'Sahifa yuklashda xato: ${error.description}';
                  _isLoading = false;
                });
              }
            },
          ),
        );

      // URL'ni yuklash
      await _webViewController.loadRequest(loginUrl);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'WebView sozlashda xato: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // 3. Callback'ni qayta ishlash
  Future<void> _handleCallback(String url) async {
    try {
      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'MyID xatosi: $error';
            _isLoading = false;
          });
        }
        return;
      }

      if (code != null && state != null) {
        // State (session_id) ni tekshirish
        if (state != _sessionId) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Session ID mos kelmadi';
              _isLoading = false;
            });
          }
          return;
        }

        // Code bilan user ma'lumotlarini olish
        await _getUserInfo(code);
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Callback ma\'lumotlari noto\'liq';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Callback qayta ishlashda xato: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // 4. User ma'lumotlarini olish
  Future<void> _getUserInfo(String code) async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // Bu yerda backend'ga code yuborib, user ma'lumotlarini olish kerak
      // Hozircha mock data bilan test qilamiz
      final userData = {
        'user_id': 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        'full_name': 'Test User',
        'phone': '+998901234567',
        'verified': true,
        'timestamp': DateTime.now().toIso8601String(),
        'code': code,
      };

      // Ma'lumotlarni saqlash
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(userData));

      if (mounted) {
        // Home sahifasiga o'tish
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'User ma\'lumotlarini olishda xato: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2E1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MyID ga kirish',
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

    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_sessionId != null) {
      return Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF15803D)),
              ),
            ),
        ],
      );
    }

    return const Center(child: Text('Kutilmagan holat'));
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF15803D)),
          const SizedBox(height: 24),
          Text(
            'MyID bilan bog\'lanmoqda...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
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
              height: 48,
              child: ElevatedButton(
                onPressed: _initializeSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Qayta urinish',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
