import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// MyID Jadval So'rovlari
///
/// Bu servis MyID integratsiyasining har bir jadvalini amalga oshiradi:
/// - 1-jadval: Access Token olish (client_id va client_secret bilan)
/// - 2-jadval: Session yaratish
/// - 3-jadval: Foydalanuvchi ma'lumotlarini olish
class MyIdTableRequests {
  /// Backend server URL
  static const String _backendUrl = 'https://myid-backend.vercel.app';

  /// 1-JADVAL: Access Token Olish
  ///
  /// So'rov parametrlari:
  /// - client_id: Mijoz identifikatori (tor)
  /// - client_secret: Mijoz siri (tor)
  ///
  /// Javob:
  /// - access_token: Token (200)
  /// - expires_in: Amal qilish muddati
  /// - token_type: Token turi
  ///
  /// Foydalanish:
  /// ```dart
  /// final result = await MyIdTableRequests.table1GetAccessToken(
  ///   clientId: 'quyosh_24_sdk-...',
  ///   clientSecret: 'JRgNV6Av8D...',
  /// );
  /// ```
  static Future<Map<String, dynamic>> table1GetAccessToken({
    required String clientId,
    required String clientSecret,
  }) async {
    try {
      debugPrint('📤 [1-JADVAL] Access token so\'rovi yuborilmoqda...');
      debugPrint('   client_id: ${clientId.substring(0, 10)}...');

      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/v1/access-token'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'client_id': clientId,
              'client_secret': clientSecret,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📥 [1-JADVAL] Javob olindi: ${response.statusCode}');

        if (data['success'] == true) {
          final accessToken = data['access_token'];
          final expiresIn = data['expires_in'];
          final tokenType = data['token_type'];

          debugPrint('✅ [1-JADVAL] Access token olindi');
          debugPrint('   Token uzunligi: ${accessToken.length}');
          debugPrint('   Amal qilish muddati: $expiresIn soniya');

          return {
            'success': true,
            'access_token': accessToken,
            'expires_in': expiresIn,
            'token_type': tokenType,
          };
        }
        return {
          'success': false,
          'error': 'Access token ma\'lumotlari noto\'g\'ri',
        };
      } else {
        return {
          'success': false,
          'error': 'Backend xatosi: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      debugPrint('❌ [1-JADVAL] Xatolik: $e');
      return {'success': false, 'error': 'So\'rov yuborishda xato: $e'};
    }
  }

  /// 2-JADVAL: Session Yaratish
  ///
  /// So'rov parametrlari:
  /// - access_token: 1-jadvaldan olingan token
  ///
  /// Javob (MAJBURIY MAYDONLAR):
  /// - session_id: Session identifikatori (UUID, 36 belgi) - MAJBURIY
  /// - expires_in: Amal qilish muddati (soniya) - MAJBURIY
  /// - token_type: Token turi (Bearer, 50 belgi max) - MAJBURIY
  /// - access_token: JWT token (512+ belgi) - MAJBURIY
  static Future<Map<String, dynamic>> table2CreateSession({
    required String accessToken,
  }) async {
    try {
      debugPrint('📤 [2-JADVAL] Session yaratish so\'rovi yuborilmoqda...');
      debugPrint('   Access token: ${accessToken.substring(0, 50)}...');

      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/v1/session'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: json.encode({'access_token': accessToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📥 [2-JADVAL] Javob olindi: ${response.statusCode}');

        if (data['success'] == true) {
          final responseData = data;

          // MAJBURIY MAYDONLARNI TEKSHIRISH
          final validationErrors = <String>[];

          // 1. session_id tekshirish (UUID, 36 belgi)
          final sessionId = responseData['session_id'];
          if (sessionId == null || sessionId.isEmpty) {
            validationErrors.add('session_id majburiy');
          } else if (sessionId is! String) {
            validationErrors.add('session_id string bo\'lishi kerak');
          } else if (sessionId.length != 36) {
            validationErrors.add(
              'session_id uzunligi 36 belgi bo\'lishi kerak (hozir: ${sessionId.length})',
            );
          }

          // 2. expires_in tekshirish (soniya)
          final expiresIn = responseData['expires_in'];
          if (expiresIn == null) {
            validationErrors.add('expires_in majburiy');
          } else if (expiresIn is! int && expiresIn is! num) {
            validationErrors.add('expires_in raqam bo\'lishi kerak');
          } else if ((expiresIn as num) <= 0) {
            validationErrors.add('expires_in musbat raqam bo\'lishi kerak');
          }

          // 3. token_type tekshirish (Bearer, 50 belgi max)
          final tokenType = responseData['token_type'];
          if (tokenType == null || tokenType.isEmpty) {
            validationErrors.add('token_type majburiy');
          } else if (tokenType is! String) {
            validationErrors.add('token_type string bo\'lishi kerak');
          } else if (tokenType.length > 50) {
            validationErrors.add(
              'token_type 50 belgidan ko\'p bo\'lmasligi kerak (hozir: ${tokenType.length})',
            );
          } else if (tokenType != 'Bearer') {
            validationErrors.add(
              'token_type "Bearer" bo\'lishi kerak (hozir: $tokenType)',
            );
          }

          // 4. access_token tekshirish (JWT, 512+ belgi)
          final newAccessToken = responseData['access_token'];
          if (newAccessToken == null || newAccessToken.isEmpty) {
            validationErrors.add('access_token majburiy');
          } else if (newAccessToken is! String) {
            validationErrors.add('access_token string bo\'lishi kerak');
          } else if (newAccessToken.length < 512) {
            validationErrors.add(
              'access_token 512 belgidan ko\'p bo\'lishi kerak (hozir: ${newAccessToken.length})',
            );
          } else if (!newAccessToken.contains('.')) {
            validationErrors.add(
              'access_token JWT format bo\'lishi kerak (3 ta nuqta bo\'lishi kerak)',
            );
          }

          // Agar validatsiya xatosi bo'lsa
          if (validationErrors.isNotEmpty) {
            debugPrint('❌ [2-JADVAL] Validatsiya xatosi:');
            for (final error in validationErrors) {
              debugPrint('   - $error');
            }
            return {
              'success': false,
              'error': 'Session javobida validatsiya xatosi',
              'validation_errors': validationErrors,
            };
          }

          debugPrint('✅ [2-JADVAL] Session yaratildi va validatsiya o\'tdi');
          debugPrint('   Session ID: $sessionId');
          debugPrint('   Amal qilish muddati: $expiresIn soniya');
          debugPrint('   Token turi: $tokenType');
          debugPrint('   Access token uzunligi: ${newAccessToken.length}');

          return {
            'success': true,
            'session_id': sessionId,
            'expires_in': expiresIn,
            'token_type': tokenType,
            'access_token': newAccessToken,
          };
        }
        return {'success': false, 'error': 'Session ma\'lumotlari noto\'g\'ri'};
      } else {
        return {
          'success': false,
          'error': 'Backend xatosi: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      debugPrint('❌ [2-JADVAL] Xatolik: $e');
      return {'success': false, 'error': 'So\'rov yuborishda xato: $e'};
    }
  }

  /// 3-JADVAL: Foydalanuvchi Ma'lumotlarini Olish
  ///
  /// So'rov parametrlari:
  /// - code: SDK'dan olingan kod
  /// - accessToken: 2-jadvaldan olingan token (Authorization header'da)
  ///
  /// Javob:
  /// - profile: Foydalanuvchi profili (200)
  /// - pinfl: Shaxsiy identifikator
  /// - name: To'liq ism
  /// - surname: Familiyasi
  /// - patronymic: Otasining ismi
  /// - birth_date: Tug'ilgan sana
  /// - gender: Jinsiyati (M/F)
  /// - nationality: Millati
  /// - passport_number: Pasport raqami
  /// - passport_series: Pasport seriyasi
  /// - passport_issue_date: Pasport berilgan sana
  /// - passport_expiry_date: Pasport muddati tugash sanasi
  /// - passport_issuer: Pasport bergan organ
  /// - address: Yashash manzili
  /// - phone: Telefon raqami
  /// - email: Email manzili
  ///
  /// Foydalanish:
  /// ```dart
  /// final result = await MyIdTableRequests.table3GetUserData(
  ///   code: 'user-code',
  ///   accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  /// );
  /// ```
  static Future<Map<String, dynamic>> table3GetUserData({
    required String code,
    required String accessToken,
  }) async {
    try {
      debugPrint(
        '📤 [3-JADVAL] Foydalanuvchi ma\'lumotlari so\'rovi yuborilmoqda...',
      );
      debugPrint('   Code: ${code.substring(0, 10)}...');
      debugPrint('   Token: ${accessToken.substring(0, 50)}...');

      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/v1/user-data'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: json.encode({'code': code}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📥 [3-JADVAL] Javob olindi: ${response.statusCode}');

        if (data['success'] == true) {
          final userData = data['profile'];

          // MAJBURIY MAYDONLARNI TEKSHIRISH
          final validationErrors = <String>[];

          // 1. pinfl tekshirish
          final pinfl = userData['pinfl'];
          if (pinfl == null || pinfl.isEmpty) {
            validationErrors.add('pinfl majburiy');
          } else if (pinfl is! String) {
            validationErrors.add('pinfl string bo\'lishi kerak');
          } else if (pinfl.length != 14) {
            validationErrors.add('pinfl uzunligi 14 belgi bo\'lishi kerak');
          }

          // 2. name tekshirish
          final name = userData['name'];
          if (name == null || name.isEmpty) {
            validationErrors.add('name majburiy');
          } else if (name is! String) {
            validationErrors.add('name string bo\'lishi kerak');
          }

          // 3. surname tekshirish
          final surname = userData['surname'];
          if (surname == null || surname.isEmpty) {
            validationErrors.add('surname majburiy');
          } else if (surname is! String) {
            validationErrors.add('surname string bo\'lishi kerak');
          }

          // 4. birth_date tekshirish
          final birthDate = userData['birth_date'];
          if (birthDate == null || birthDate.isEmpty) {
            validationErrors.add('birth_date majburiy');
          } else if (birthDate is! String) {
            validationErrors.add('birth_date string bo\'lishi kerak');
          }

          // 5. gender tekshirish
          final gender = userData['gender'];
          if (gender == null || gender.isEmpty) {
            validationErrors.add('gender majburiy');
          } else if (gender is! String) {
            validationErrors.add('gender string bo\'lishi kerak');
          } else if (gender != 'M' && gender != 'F') {
            validationErrors.add('gender "M" yoki "F" bo\'lishi kerak');
          }

          // Agar validatsiya xatosi bo'lsa
          if (validationErrors.isNotEmpty) {
            debugPrint('❌ [3-JADVAL] Validatsiya xatosi:');
            for (final error in validationErrors) {
              debugPrint('   - $error');
            }
            return {
              'success': false,
              'error': 'Foydalanuvchi ma\'lumotlarida validatsiya xatosi',
              'validation_errors': validationErrors,
            };
          }

          debugPrint('✅ [3-JADVAL] Foydalanuvchi ma\'lumotlari olindi');
          debugPrint('   PINFL: $pinfl');
          debugPrint('   Ism: $name');
          debugPrint('   Familiya: $surname');

          return {'success': true, 'profile': userData};
        }
        return {
          'success': false,
          'error': 'Foydalanuvchi ma\'lumotlari noto\'g\'ri',
        };
      } else {
        return {
          'success': false,
          'error': 'Backend xatosi: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      debugPrint('❌ [3-JADVAL] Xatolik: $e');
      return {'success': false, 'error': 'So\'rov yuborishda xato: $e'};
    }
  }

  /// Barcha jadvallarni ketma-ketlik bilan bajarish
  ///
  /// Foydalanish:
  /// ```dart
  /// final result = await MyIdTableRequests.executeAllTables(
  ///   clientId: 'quyosh_24_sdk-...',
  ///   clientSecret: 'JRgNV6Av8D...',
  ///   code: 'user-code',
  ///   onStatusUpdate: (status) => print(status),
  /// );
  /// ```
  static Future<Map<String, dynamic>> executeAllTables({
    required String clientId,
    required String clientSecret,
    required String code,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      // 1-JADVAL: Access Token
      onStatusUpdate?.call('1-jadval: Access token olinmoqda...');
      final table1Result = await table1GetAccessToken(
        clientId: clientId,
        clientSecret: clientSecret,
      );

      if (table1Result['success'] != true) {
        return {
          'success': false,
          'error': table1Result['error'] ?? '1-jadval xatosi',
        };
      }

      final accessToken1 = table1Result['access_token'];
      onStatusUpdate?.call('✅ 1-jadval tugadi');

      // 2-JADVAL: Session Yaratish
      onStatusUpdate?.call('2-jadval: Session yaratilmoqda...');
      final table2Result = await table2CreateSession(accessToken: accessToken1);

      if (table2Result['success'] != true) {
        return {
          'success': false,
          'error': table2Result['error'] ?? '2-jadval xatosi',
        };
      }

      final accessToken2 = table2Result['access_token'];
      onStatusUpdate?.call('✅ 2-jadval tugadi');

      // 3-JADVAL: Foydalanuvchi Ma'lumotlari (2-jadvaldan olingan token bilan)
      onStatusUpdate?.call(
        '3-jadval: Foydalanuvchi ma\'lumotlari olinmoqda...',
      );
      final table3Result = await table3GetUserData(
        code: code,
        accessToken: accessToken2,
      );

      if (table3Result['success'] != true) {
        return {
          'success': false,
          'error': table3Result['error'] ?? '3-jadval xatosi',
        };
      }

      onStatusUpdate?.call('✅ 3-jadval tugadi');

      return {
        'success': true,
        'table1': table1Result,
        'table2': table2Result,
        'table3': table3Result,
      };
    } catch (e) {
      return {'success': false, 'error': 'Jadvallarni bajarishda xato: $e'};
    }
  }
}
