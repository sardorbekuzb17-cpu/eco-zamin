import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final Map<String, dynamic> updateMessage;
  final String downloadUrl;
  final String langCode;
  final bool isForceUpdate;

  const ForceUpdateDialog({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    required this.updateMessage,
    required this.downloadUrl,
    required this.langCode,
    this.isForceUpdate = true,
  });

  Future<void> _launchUrl() async {
    final uri = Uri.parse(downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isForceUpdate, // Majburiy yangilanishda orqaga qaytib bo'lmaydi
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF15803D), Color(0xFF166534)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rasm va sarlavha
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.system_update,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isForceUpdate
                          ? (langCode == 'uz'
                                ? 'Majburiy yangilanish'
                                : langCode == 'ru'
                                ? 'Обязательное обновление'
                                : 'Required Update')
                          : (langCode == 'uz'
                                ? 'Yangilanish mavjud'
                                : langCode == 'ru'
                                ? 'Доступно обновление'
                                : 'Update Available'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Mazmun
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Versiya ma'lumotlari
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              langCode == 'uz'
                                  ? 'Joriy versiya'
                                  : langCode == 'ru'
                                  ? 'Текущая версия'
                                  : 'Current version',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              currentVersion,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2E1A),
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF15803D),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              langCode == 'uz'
                                  ? 'Yangi versiya'
                                  : langCode == 'ru'
                                  ? 'Новая версия'
                                  : 'New version',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              latestVersion,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Xabar
                    Text(
                      updateMessage[langCode] ?? updateMessage['uz'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Yangilash tugmasi
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _launchUrl,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15803D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              langCode == 'uz'
                                  ? 'Hozir yangilash'
                                  : langCode == 'ru'
                                  ? 'Обновить сейчас'
                                  : 'Update Now',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Keyinroq tugmasi (faqat majburiy bo'lmasa)
                    if (!isForceUpdate) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            langCode == 'uz'
                                ? 'Keyinroq'
                                : langCode == 'ru'
                                ? 'Позже'
                                : 'Later',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ],
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
