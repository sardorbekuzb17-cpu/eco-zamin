import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LikeService {
  // JSONBin.io - bepul public bin
  static const String _binUrl =
      'https://api.jsonbin.io/v3/b/678479e8ad19ca34f8e5c8a0';
  static const String _masterKey = '\$2a\$10\$Hs8YrJqKzQvJqKzQvJqKzu';

  static Map<String, int> _cache = {};

  // Like'larni serverdan yuklash
  static Future<Map<String, int>> fetchLikes() async {
    try {
      final response = await http.get(
        Uri.parse(_binUrl),
        headers: {'X-Master-Key': _masterKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final record = data['record'] as Map<String, dynamic>? ?? {};
        _cache = record.map((k, v) => MapEntry(k, v as int));
        return _cache;
      }
    } catch (e) {
      debugPrint('Error fetching likes: $e');
    }
    return _cache;
  }

  // Like qo'shish
  static Future<int> addLike(String productId) async {
    _cache[productId] = (_cache[productId] ?? 0) + 1;
    await _saveLikes();
    return _cache[productId]!;
  }

  // Like olib tashlash
  static Future<int> removeLike(String productId) async {
    _cache[productId] = (_cache[productId] ?? 1) - 1;
    if (_cache[productId]! < 0) _cache[productId] = 0;
    await _saveLikes();
    return _cache[productId]!;
  }

  // Serverga saqlash
  static Future<void> _saveLikes() async {
    try {
      await http.put(
        Uri.parse(_binUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Master-Key': _masterKey,
        },
        body: jsonEncode(_cache),
      );
    } catch (e) {
      debugPrint('Error saving likes: $e');
    }
  }

  // Cache dan olish
  static int getLikeCount(String productId) {
    return _cache[productId] ?? 0;
  }
}
