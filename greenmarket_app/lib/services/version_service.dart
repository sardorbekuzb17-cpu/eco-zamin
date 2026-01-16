import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  // Vercel API URL - versiya ma'lumotlarini saqlash uchun
  static const String _apiUrl =
      'https://greenmarket-api.vercel.app/api/version';

  // Joriy versiyani olish
  static Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  // Joriy build raqamini olish
  static Future<String> getCurrentBuildNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  // Serverdan eng so'nggi versiyani tekshirish
  static Future<Map<String, dynamic>> checkForUpdate() async {
    try {
      final currentVersion = await getCurrentVersion();
      final currentBuildNumber = await getCurrentBuildNumber();

      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['latestVersion'] as String;
        final latestBuildNumber = data['latestBuildNumber'] as int;
        final isForceUpdate = data['isForceUpdate'] as bool;
        final updateMessage = data['updateMessage'] as Map<String, dynamic>;
        final downloadUrl = data['downloadUrl'] as String;

        // Build raqamini solishtirish (aniqroq)
        final currentBuild = int.parse(currentBuildNumber);
        final needsUpdate = currentBuild < latestBuildNumber;

        return {
          'needsUpdate': needsUpdate,
          'isForceUpdate': isForceUpdate && needsUpdate,
          'currentVersion': currentVersion,
          'latestVersion': latestVersion,
          'updateMessage': updateMessage,
          'downloadUrl': downloadUrl,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Versiya tekshirishda xatolik: $e');
      }
    }

    // Xatolik bo'lsa, yangilanish kerak emas deb qaytaramiz
    return {
      'needsUpdate': false,
      'isForceUpdate': false,
      'currentVersion': await getCurrentVersion(),
      'latestVersion': await getCurrentVersion(),
      'updateMessage': {
        'uz': 'Yangilanish mavjud emas',
        'ru': 'Обновление недоступно',
        'en': 'No update available',
      },
      'downloadUrl': '',
    };
  }

  // Versiyalarni solishtirish (1.0.0 formatida)
  static bool isVersionGreater(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (v1Parts[i] > v2Parts[i]) return true;
      if (v1Parts[i] < v2Parts[i]) return false;
    }
    return false;
  }
}
