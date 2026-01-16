import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';

class MyIDService {
  static const String _baseUrl = 'https://sso.egov.uz';
  static const String _clientId =
      'greenmarket_mobile'; // O'z client_id'ingizni kiriting
  static const String _redirectUri = 'greenmarket://myid_callback';
  static const String _scope = 'address,contacts,doc_data,common_data';

  // MyID orqali kirish URL'ini olish
  static String getAuthorizationUrl() {
    final state = _generateState();
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);

    // State va code_verifier'ni saqlash
    _saveAuthData(state, codeVerifier);

    return '$_baseUrl/sso/oauth/Authorization.do?'
        'response_type=one_code&'
        'client_id=$_clientId&'
        'redirect_uri=${Uri.encodeComponent(_redirectUri)}&'
        'scope=$_scope&'
        'state=$state&'
        'code_challenge=$codeChallenge&'
        'code_challenge_method=S256';
  }

  // State generatsiya qilish
  static String _generateState() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }

  // Code verifier generatsiya qilish
  static String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }

  // Code challenge generatsiya qilish
  static String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  // Auth ma'lumotlarini saqlash
  static Future<void> _saveAuthData(String state, String codeVerifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('myid_state', state);
    await prefs.setString('myid_code_verifier', codeVerifier);
  }

  // Callback'dan token olish
  static Future<Map<String, dynamic>> handleCallback(
    String code,
    String state,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final savedState = prefs.getString('myid_state');
    final codeVerifier = prefs.getString('myid_code_verifier');

    // State tekshirish
    if (state != savedState) {
      throw Exception('Invalid state parameter');
    }

    try {
      // Token olish
      final response = await http.post(
        Uri.parse('$_baseUrl/sso/oauth/Authorization.do'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'one_authorization_code',
          'code': code,
          'client_id': _clientId,
          'redirect_uri': _redirectUri,
          'code_verifier': codeVerifier,
        },
      );

      if (response.statusCode == 200) {
        final tokenData = json.decode(response.body);

        if (tokenData['access_token'] != null) {
          // Token'larni saqlash
          await prefs.setString('myid_access_token', tokenData['access_token']);
          await prefs.setString(
            'myid_refresh_token',
            tokenData['refresh_token'],
          );

          // Foydalanuvchi ma'lumotlarini olish
          final userData = await getUserData(tokenData['access_token']);
          return userData;
        } else {
          throw Exception('Token olishda xatolik');
        }
      } else {
        throw Exception('HTTP xatolik: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('MyID callback xatolik: $e');
    }
  }

  // Foydalanuvchi ma'lumotlarini olish
  static Future<Map<String, dynamic>> getUserData(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sso/oauth/Authorization.do'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'grant_type': 'access_token', 'access_token': accessToken},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Ma'lumotlarni formatlash
        final userData = {
          'pin': data['pin'],
          'fullName':
              '${data['sur_name']} ${data['first_name']} ${data['middle_name']}',
          'firstName': data['first_name'],
          'lastName': data['sur_name'],
          'middleName': data['middle_name'],
          'birthDate': data['birth_date'],
          'citizenship': data['citizenship'],
          'nationality': data['nationality'],
          'gender': data['sex'],
          'passportSerial': data['doc_data']?['pass_data'],
          'passportNumber': data['doc_data']?['pass_data'],
          'passportIssueDate': data['doc_data']?['issued_date'],
          'passportExpireDate': data['doc_data']?['expiry_date'],
          'address': {
            'region': data['address']?['region'],
            'district': data['address']?['district'],
            'address': data['address']?['address'],
            'cadastre': data['address']?['cadastre'],
          },
          'phone': data['contacts']?['phone'],
          'email': data['contacts']?['email'],
        };

        // Foydalanuvchi ma'lumotlarini saqlash
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(userData));

        return userData;
      } else {
        throw Exception('HTTP xatolik: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Foydalanuvchi ma\'lumotlarini olishda xatolik: $e');
    }
  }

  // Refresh token bilan yangi access token olish
  static Future<String> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('myid_refresh_token');

    if (refreshToken == null) {
      throw Exception('Refresh token topilmadi');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sso/oauth/Authorization.do'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': _clientId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['access_token'] != null) {
          await prefs.setString('myid_access_token', data['access_token']);
          return data['access_token'];
        } else {
          throw Exception('Token yangilashda xatolik');
        }
      } else {
        throw Exception('HTTP xatolik: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Token yangilash xatolik: $e');
    }
  }

  // Chiqish
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('myid_access_token');
    await prefs.remove('myid_refresh_token');
    await prefs.remove('user_data');
    await prefs.remove('myid_state');
    await prefs.remove('myid_code_verifier');
  }

  // Foydalanuvchi tizimga kirganmi?
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('myid_access_token');
  }

  // Saqlangan foydalanuvchi ma'lumotlarini olish
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }
}
