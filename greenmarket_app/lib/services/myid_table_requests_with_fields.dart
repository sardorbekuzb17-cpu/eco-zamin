import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// MyID 2-Jadval: Pasport Maydonlari Bilan Session Yaratish
///
/// Bu servis 2-jadvalda optional maydonlar bilan session yaratadi:
/// - phone_number: Telefon raqami
/// - birth_date: Tug'ilgan sana
/// - is_resident: Rezident yoki yo'q
/// - pass_data: Pasport seriyasi
/// - threshold: Yuz taqqoslash chegarasi
class MyIdTableRequestsWithFields {
  /// Backend server URL
  static const String _backendUrl =
      'https://greenmarket-backend-lilac.vercel.app';

  /// 2-JADVAL: Session Yaratish (Pasport Maydonlari Bilan)
  ///
  /// So'rov parametrlari (IXTIYORIY):
  /// - accessToken: 1-jadvaldan olingan token (Authorization header'da)
  /// - phoneNumber: Telefon raqami (min: 12, max: 13 belgi)
  /// - birthDate: Tug'ilgan sana (YYYY-MM-DD format)
  /// - isResident: Rezident yoki yo'q (default: true)
  /// - passData: Pasport seriyasi va raqami
  /// - threshold: Yuz taqqoslash chegarasi (0.5 - 0.99)
  ///
  /// Javob:
  /// - session_id: Session identifikatori (UUID)
  /// - access_token: Keyingi so'rovlar uchun token
  /// - expires_in: Amal qilish muddati (soniya)
  /// - token_type: Token turi (Bearer)
  ///
  /// Foydalanish:
  /// ```dart
  /// final result = await MyIdTableRequestsWithFields.table2CreateSessionWithFields(
  ///   accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  ///   phoneNumber: '998901234567',
  ///   birthDate: '1990-01-15',
  ///   isResident: true,
  ///   passData: 'AA123456',
  ///   threshold: 0.85,
  /// );
  /// ```
  static Future<Map<String, dynamic>> table2CreateSessionWithFields({
    required String accessToken,
    String? phoneNumber,
    String? birthDate,
    bool? isResident,
    String? passData,
    double? threshold,
  }) async {
    try {
      debugPrint('📤 [2-JADVAL] Session yaratish (maydonlar bilan)...');
      debugPrint('   Access token: ${accessToken.substring(0, 50)}...');

      // Maydonlarni validatsiya qilish
      final validationErrors = <String>[];

      // phone_number validatsiyasi
      if (phoneNumber != null) {
        if (phoneNumber.isEmpty) {
          validationErrors.add('phone_number bo\'sh bo\'lmasligi kerak');
        } else if (phoneNumber.length < 12 || phoneNumber.length > 13) {
          validationErrors.add(
            'phone_number uzunligi 12-13 belgi bo\'lishi kerak (hozir: ${phoneNumber.length})',
          );
        } else if (!RegExp(r'^\+?998\d{9}$').hasMatch(phoneNumber)) {
          validationErrors.add(
            'phone_number 998901234567 kabi formatda bo\'lishi kerak',
          );
        }
      }

      // birth_date validatsiyasi
      if (birthDate != null) {
        if (birthDate.isEmpty) {
          validationErrors.add('birth_date bo\'sh bo\'lmasligi kerak');
        } else if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthDate)) {
          validationErrors.add(
            'birth_date YYYY-MM-DD formatida bo\'lishi kerak',
          );
        } else {
          try {
            DateTime.parse(birthDate);
          } catch (e) {
            validationErrors.add(
              'birth_date to\'g\'ri sana bo\'lmasligi kerak',
            );
          }
        }
      }

      // is_resident validatsiyasi
      if (isResident != null) {
        // isResident bool bo'lishi kerak, lekin Dart'da null-safety tufayli bu tekshiruv keraksiz
        // Lekin qo'shimcha xavfsizlik uchun qoldiramiz
      }

      // pass_data validatsiyasi
      if (passData != null) {
        if (passData.isEmpty) {
          validationErrors.add('pass_data bo\'sh bo\'lmasligi kerak');
        } else if (passData.length < 2) {
          validationErrors.add(
            'pass_data kamida 2 belgidan iborat bo\'lishi kerak',
          );
        }
      }

      // threshold validatsiyasi
      if (threshold != null) {
        if (threshold < 0.5 || threshold > 0.99) {
          validationErrors.add('threshold 0.5 dan 0.99 gacha bo\'lishi kerak');
        }
      }

      // Agar validatsiya xatosi bo'lsa
      if (validationErrors.isNotEmpty) {
        debugPrint('❌ [2-JADVAL] Validatsiya xatosi:');
        for (final error in validationErrors) {
          debugPrint('   - $error');
        }
        return {
          'success': false,
          'error': 'So\'rov maydonlarida validatsiya xatosi',
          'validation_errors': validationErrors,
        };
      }

      // So'rov body'sini tayyorlash
      final requestBody = <String, dynamic>{};
      if (phoneNumber != null) requestBody['phone_number'] = phoneNumber;
      if (birthDate != null) requestBody['birth_date'] = birthDate;
      if (isResident != null) requestBody['is_resident'] = isResident;
      if (passData != null) requestBody['pass_data'] = passData;
      if (threshold != null) requestBody['threshold'] = threshold;

      debugPrint('   So\'rov body: ${json.encode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/myid/create-session-with-fields'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📥 [2-JADVAL] Javob olindi: ${response.statusCode}');

        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'];

          // MAJBURIY MAYDONLARNI TEKSHIRISH
          final validationErrors = <String>[];

          // 1. session_id tekshirish
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

          // 2. access_token tekshirish
          final newAccessToken = responseData['access_token'];
          if (newAccessToken == null || newAccessToken.isEmpty) {
            validationErrors.add('access_token majburiy');
          } else if (newAccessToken is! String) {
            validationErrors.add('access_token string bo\'lishi kerak');
          } else if (newAccessToken.length < 512) {
            validationErrors.add(
              'access_token 512 belgidan ko\'p bo\'lishi kerak (hozir: ${newAccessToken.length})',
            );
          }

          // 3. expires_in tekshirish
          final expiresIn = responseData['expires_in'];
          if (expiresIn == null) {
            validationErrors.add('expires_in majburiy');
          } else if (expiresIn is! int && expiresIn is! num) {
            validationErrors.add('expires_in raqam bo\'lishi kerak');
          } else if ((expiresIn as num) <= 0) {
            validationErrors.add('expires_in musbat raqam bo\'lishi kerak');
          }

          // 4. token_type tekshirish
          final tokenType = responseData['token_type'];
          if (tokenType == null || tokenType.isEmpty) {
            validationErrors.add('token_type majburiy');
          } else if (tokenType is! String) {
            validationErrors.add('token_type string bo\'lishi kerak');
          } else if (tokenType != 'Bearer') {
            validationErrors.add('token_type "Bearer" bo\'lishi kerak');
          }

          // Agar validatsiya xatosi bo'lsa
          if (validationErrors.isNotEmpty) {
            debugPrint('❌ [2-JADVAL] Javob validatsiya xatosi:');
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

          return {
            'success': true,
            'session_id': sessionId,
            'access_token': newAccessToken,
            'expires_in': expiresIn,
            'token_type': tokenType,
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

  /// 2-JADVAL: Session Yaratish (Pasport Bilan)
  ///
  /// So'rov parametrlari:
  /// - accessToken: 1-jadvaldan olingan token
  /// - passData: Pasport seriyasi va raqami
  /// - birthDate: Tug'ilgan sana (YYYY-MM-DD format)
  static Future<Map<String, dynamic>> table2CreateSessionWithPassport({
    required String accessToken,
    required String passData,
    required String birthDate,
  }) async {
    try {
      debugPrint('📤 [2-JADVAL] Session yaratish (pasport bilan)...');

      // Maydonlarni validatsiya qilish
      final validationErrors = <String>[];

      if (passData.isEmpty) {
        validationErrors.add('pass_data bo\'sh bo\'lmasligi kerak');
      }

      if (birthDate.isEmpty) {
        validationErrors.add('birth_date bo\'sh bo\'lmasligi kerak');
      } else if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthDate)) {
        validationErrors.add('birth_date YYYY-MM-DD formatida bo\'lishi kerak');
      }

      if (validationErrors.isNotEmpty) {
        debugPrint('❌ [2-JADVAL] Validatsiya xatosi:');
        for (final error in validationErrors) {
          debugPrint('   - $error');
        }
        return {
          'success': false,
          'error': 'So\'rov maydonlarida validatsiya xatosi',
          'validation_errors': validationErrors,
        };
      }

      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/myid/create-session-with-passport'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: json.encode({'pass_data': passData, 'birth_date': birthDate}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📥 [2-JADVAL] Javob olindi: ${response.statusCode}');

        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'];

          debugPrint('✅ [2-JADVAL] Session yaratildi');
          debugPrint('   Session ID: ${responseData['session_id']}');

          return {
            'success': true,
            'session_id': responseData['session_id'],
            'access_token': responseData['access_token'],
            'expires_in': responseData['expires_in'],
            'token_type': responseData['token_type'],
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
}
