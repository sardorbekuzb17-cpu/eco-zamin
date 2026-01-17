import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../config/myid_config.dart';
import '../models/myid_user.dart';

class MyIDService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Uuid _uuid = const Uuid();

  // 1. Authorization URL yaratish (WebView uchun)
  Future<Uri> generateAuthorizationUrl() async {
    try {
      // State va code verifier yaratish
      final state = _generateState();
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);

      // Saqlash
      await _storage.write(key: 'state', value: state);
      await _storage.write(key: 'code_verifier', value: codeVerifier);

      // Authorization URL yaratish
      final authUrl = Uri.parse(MyIDConfig.authEndpoint).replace(
        queryParameters: {
          'client_id': MyIDConfig.clientId,
          'redirect_uri': MyIDConfig.redirectUri,
          'response_type': 'code',
          'scope': MyIDConfig.scope,
          'state': state,
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
        },
      );

      return authUrl;
    } catch (e) {
      throw Exception('Authorization URL yaratishda xato: $e');
    }
  }

  // 1b. Authorization boshlash (tashqi brauzer uchun - eski metod)
  Future<void> startAuthorization() async {
    try {
      final authUrl = await generateAuthorizationUrl();

      // Browser'da ochish
      if (await canLaunchUrl(authUrl)) {
        await launchUrl(authUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Authorization URL ochib bo\'lmadi');
      }
    } catch (e) {
      throw Exception('Authorization boshlashda xato: $e');
    }
  }

  // 2. Authorization code bilan token olish
  Future<void> exchangeCodeForToken(String code, String state) async {
    try {
      // State tekshirish
      final savedState = await _storage.read(key: 'state');
      if (savedState != state) {
        throw Exception('State mos kelmadi - CSRF hujumi ehtimoli');
      }

      // Code verifier olish
      final codeVerifier = await _storage.read(key: 'code_verifier');
      if (codeVerifier == null) {
        throw Exception('Code verifier topilmadi');
      }

      // Basic auth
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('${MyIDConfig.clientId}:${MyIDConfig.clientSecret}'))}';

      // Request body
      final data = {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': MyIDConfig.redirectUri,
        'code_verifier': codeVerifier,
        'client_id': MyIDConfig.clientId,
      };

      // Headers
      final headers = {
        'Authorization': basicAuth,
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Client-Hash-Id': MyIDConfig.clientHashId,
      };

      // Token olish so'rovi
      final response = await _dio.post(
        MyIDConfig.tokenEndpoint,
        data: data,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final tokenData = response.data as Map<String, dynamic>;
        await _saveTokens(tokenData);

        // Tozalash
        await _storage.delete(key: 'state');
        await _storage.delete(key: 'code_verifier');
      } else {
        throw Exception('Token olishda xato: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Token exchange xato: $e');
    }
  }

  // 3. User ma'lumotlarini olish
  Future<MyIDUser> getUserInfo() async {
    try {
      // Access token olish
      final accessToken = await _storage.read(key: 'access_token');
      if (accessToken == null) {
        throw Exception('Access token topilmadi');
      }

      // Headers
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'X-Client-Hash-Id': MyIDConfig.clientHashId,
      };

      // User info so'rovi
      final response = await _dio.get(
        MyIDConfig.userInfoEndpoint,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return MyIDUser.fromJson(response.data);
      } else {
        throw Exception(
          'User ma\'lumotlarini olishda xato: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('User info olishda xato: $e');
    }
  }

  // 4. Token yangilash
  Future<void> refreshToken() async {
    try {
      // Refresh token ni olish
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        throw Exception('Refresh token topilmadi');
      }

      // Basic auth
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('${MyIDConfig.clientId}:${MyIDConfig.clientSecret}'))}';

      // Request body
      final data = {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': MyIDConfig.clientId,
      };

      // Headers
      final headers = {
        'Authorization': basicAuth,
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Client-Hash-Id': MyIDConfig.clientHashId,
      };

      // Token yangilash so'rovi
      final response = await _dio.post(
        MyIDConfig.tokenEndpoint,
        data: data,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final tokenData = response.data as Map<String, dynamic>;
        await _saveTokens(tokenData);
      } else {
        throw Exception('Token yangilashda xato: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Token yangilashda xato: $e');
    }
  }

  // 5. Chiqish (logout)
  Future<void> logout() async {
    try {
      // Saqlangan tokenlarni o'chirish
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'code_verifier');
      await _storage.delete(key: 'state');
      await _storage.delete(key: 'user_id');
    } catch (e) {
      throw Exception('Logoutda xato: $e');
    }
  }

  // 6. Tokenlar mavjudligini tekshirish
  Future<bool> hasValidToken() async {
    final accessToken = await _storage.read(key: 'access_token');
    return accessToken != null;
  }

  // 7. User ID ni olish
  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  // -------------------- Yordamchi metodlar --------------------

  // State generatsiya qilish
  String _generateState() {
    return _uuid.v4();
  }

  // Code verifier generatsiya qilish
  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }

  // Code challenge generatsiya qilish
  String _generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  // Tokenlarni saqlash
  Future<void> _saveTokens(Map<String, dynamic> tokenData) async {
    await _storage.write(
      key: 'access_token',
      value: tokenData['access_token']?.toString(),
    );

    await _storage.write(
      key: 'refresh_token',
      value: tokenData['refresh_token']?.toString(),
    );

    // User ID ni saqlash (agar mavjud bo'lsa)
    if (tokenData['id_token'] != null) {
      try {
        final idToken = tokenData['id_token'].toString();
        final parts = idToken.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          final userId = payload['sub']?.toString();
          if (userId != null) {
            await _storage.write(key: 'user_id', value: userId);
          }
        }
      } catch (e) {
        // ID tokenni decode qilishda xato
      }
    }
  }
}
