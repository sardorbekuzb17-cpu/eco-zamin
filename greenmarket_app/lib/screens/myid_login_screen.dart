import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/myid_services.dart';
import '../config/myid_config.dart';

class MyIDLoginScreen extends StatefulWidget {
  final Function(String, String) onCodeReceived; // code va state
  final Function(String) onError;

  const MyIDLoginScreen({
    super.key,
    required this.onCodeReceived,
    required this.onError,
  });

  @override
  State<MyIDLoginScreen> createState() => _MyIDLoginScreenState();
}

class _MyIDLoginScreenState extends State<MyIDLoginScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      final myIdService = MyIDService();

      // State va code verifier yaratish va saqlash
      final authUrl = await myIdService.generateAuthorizationUrl();

      // WebView controller sozlash
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) {
              // Redirect URI ni tekshirish
              if (request.url.startsWith(MyIDConfig.redirectUri)) {
                // URL ni parse qilish
                final uri = Uri.parse(request.url);
                final code = uri.queryParameters['code'];
                final state = uri.queryParameters['state'];
                final error = uri.queryParameters['error'];

                if (code != null && state != null) {
                  // Code va state ni o'tkazish
                  widget.onCodeReceived(code, state);
                  Navigator.pop(context, true);
                } else if (error != null) {
                  // Xatoni o'tkazish
                  widget.onError(error);
                  Navigator.pop(context, false);
                } else {
                  widget.onError('Noma\'lum xato');
                  Navigator.pop(context, false);
                }
                return NavigationDecision.prevent;
              }

              // Tashqi linklarni brauzerga ochish
              if (request.url.startsWith('http') &&
                  !request.url.contains('devmyid.uz')) {
                _launchExternalBrowser(request.url);
                return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            },
            onPageStarted: (url) {
              setState(() => _isLoading = true);
            },
            onPageFinished: (url) {
              setState(() => _isLoading = false);
            },
            onWebResourceError: (error) {
              widget.onError(error.description);
            },
          ),
        );

      // Authorization URL ni yuklash
      await _controller.loadRequest(authUrl);
    } catch (e) {
      widget.onError('WebView sozlashda xato: $e');
    }
  }

  Future<void> _launchExternalBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyID ga kirish'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
