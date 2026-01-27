import 'dart:convert';
import 'package:http/http.dart' as http;

class MyIdService {
  static const String baseUrl = "http://192.168.3.1:3000";

  /// Session olish
  static Future<String?> createSession(String passport) async {
    final url = Uri.parse("$baseUrl/api/myid/session");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"passport": passport}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["session_id"];
    }
    return null;
  }

  /// Natija olish
  static Future<Map?> getResult(String sessionId) async {
    final url = Uri.parse("$baseUrl/api/myid/result/$sessionId");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }

  /// Access token olish
  static Future<String?> getAccessToken(
    String clientId,
    String clientSecret,
  ) async {
    final url = Uri.parse("$baseUrl/api/myid/access-token");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"client_id": clientId, "client_secret": clientSecret}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["access_token"];
    }
    return null;
  }

  /// Foydalanuvchi ma'lumotlarini olish
  static Future<Map?> getUserData(String code, String accessToken) async {
    final url = Uri.parse("$baseUrl/api/myid/user-data");
    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode({"code": code}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["profile"];
    }
    return null;
  }
}
