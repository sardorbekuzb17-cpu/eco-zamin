// ignore_for_file: avoid_print

// MyID OAuth Access Token olish - Test misoli
// Bu faylni ishlatish shart emas, faqat misol uchun

import 'package:flutter/material.dart';
import 'lib/services/myid_backend_service.dart';
import 'lib/config/myid_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔐 MyID OAuth Access Token Test');
  print('================================\n');

  // 1. Client ma'lumotlarini ko'rsatish
  print('📋 Client Ma\'lumotlari:');
  print('Client ID: ${MyIDConfig.clientId}');
  print('Client Secret: ${MyIDConfig.clientSecret.substring(0, 20)}...\n');

  // 2. Access Token olish
  print('🔄 Access Token so\'ralyapti...\n');

  final result = await MyIdBackendService.getAccessToken(
    clientId: MyIDConfig.clientId,
    clientSecret: MyIDConfig.clientSecret,
  );

  // 3. Natijani ko'rsatish
  if (result['success'] == true) {
    print('✅ Muvaffaqiyatli!\n');
    print('Token Type: ${result['token_type']}');

    final expiresIn = result['expires_in'] as int;
    final hours = expiresIn ~/ 3600;
    final days = expiresIn ~/ 86400;

    print('Expires In: $expiresIn soniya ($hours soat / $days kun)');
    print('Access Token: ${result['access_token']?.substring(0, 50)}...\n');

    // 4. Token'ni ishlatish misoli
    print('📝 Ishlatish misoli:');
    print('Authorization: Bearer ${result['access_token']}\n');
  } else {
    print('❌ Xatolik: ${result['error']}\n');
    if (result['error_details'] != null) {
      print('Tafsilotlar: ${result['error_details']}');
    }
  }

  print('================================');
  print('✅ Test tugadi');
}
