import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkStorage {
  static const _key = 'bookmarked_posts';

  static Future<List<int>> getBookmarkedIds() async {
    final sp = await SharedPreferences.getInstance();
    final jsonStr = sp.getString(_key);
    if (jsonStr == null) return [];
    return List<int>.from(json.decode(jsonStr));
  }

  static Future<void> saveBookmarkedIds(List<int> ids) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, json.encode(ids));
  }
}
