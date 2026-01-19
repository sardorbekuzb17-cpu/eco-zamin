import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// MyID xato dialog komponenti
/// Ko'p tilda xato xabarlarini ko'rsatadi va qayta urinish imkoniyatini beradi
class MyIdErrorDialog extends StatelessWidget {
  final String errorType;
  final String? customMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const MyIdErrorDialog({
    super.key,
    required this.errorType,
    this.customMessage,
    this.onRetry,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Xato turiga qarab to'g'ri xabarlarni olish
    String title = l10n.translate('myid_error_title');
    String message = _getErrorMessage(l10n);
    String description = _getErrorDescription(l10n);
    IconData icon = _getErrorIcon();
    Color iconColor = _getErrorColor();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Xato ikoni
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(icon, size: 48, color: iconColor),
            ),
            const SizedBox(height: 24),

            // Sarlavha
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2E1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Xato xabari
            Text(
              customMessage ?? message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Tavsif
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Tugmalar
            Row(
              children: [
                // Orqaga tugmasi
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        l10n.translate('myid_go_back'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                if (onCancel != null && onRetry != null)
                  const SizedBox(width: 12),

                // Qayta urinish tugmasi
                if (onRetry != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.translate('myid_try_again'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getErrorMessage(AppLocalizations l10n) {
    switch (errorType) {
      case 'network':
        return l10n.translate('myid_network_error');
      case 'session':
        return l10n.translate('myid_session_error');
      case 'session_not_found':
        return l10n.translate('myid_session_not_found');
      case 'session_expired':
        return l10n.translate('myid_session_expired');
      case 'verification_failed':
        return l10n.translate('myid_verification_failed');
      case 'cancelled':
        return l10n.translate('myid_cancelled');
      case 'sdk_error':
        return l10n.translate('myid_sdk_error');
      case 'data_error':
        return l10n.translate('myid_data_error');
      case 'server_error':
        return l10n.translate('myid_server_error');
      case 'timeout':
        return l10n.translate('myid_timeout');
      default:
        return l10n.translate('myid_unknown_error');
    }
  }

  String _getErrorDescription(AppLocalizations l10n) {
    switch (errorType) {
      case 'network':
        return l10n.translate('myid_network_error_desc');
      case 'session':
        return l10n.translate('myid_session_error_desc');
      case 'session_expired':
        return l10n.translate('myid_session_expired_desc');
      case 'verification_failed':
        return l10n.translate('myid_verification_failed_desc');
      case 'cancelled':
        return l10n.translate('myid_cancelled_desc');
      case 'sdk_error':
        return l10n.translate('myid_sdk_error_desc');
      case 'data_error':
        return l10n.translate('myid_data_error_desc');
      case 'server_error':
        return l10n.translate('myid_server_error_desc');
      case 'timeout':
        return l10n.translate('myid_timeout_desc');
      default:
        return l10n.translate('myid_unknown_error_desc');
    }
  }

  IconData _getErrorIcon() {
    switch (errorType) {
      case 'network':
        return Icons.wifi_off;
      case 'session':
      case 'session_not_found':
      case 'session_expired':
        return Icons.access_time;
      case 'verification_failed':
        return Icons.face_retouching_off;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'sdk_error':
        return Icons.error_outline;
      case 'data_error':
        return Icons.save_outlined;
      case 'server_error':
        return Icons.cloud_off;
      case 'timeout':
        return Icons.timer_off;
      default:
        return Icons.error_outline;
    }
  }

  Color _getErrorColor() {
    switch (errorType) {
      case 'cancelled':
        return Colors.orange;
      case 'network':
      case 'server_error':
        return Colors.blue;
      case 'timeout':
        return Colors.amber;
      default:
        return Colors.red;
    }
  }

  /// Xato dialog'ini ko'rsatish uchun statik metod
  static Future<void> show({
    required BuildContext context,
    required String errorType,
    String? customMessage,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MyIdErrorDialog(
        errorType: errorType,
        customMessage: customMessage,
        onRetry: onRetry,
        onCancel: onCancel,
      ),
    );
  }
}
