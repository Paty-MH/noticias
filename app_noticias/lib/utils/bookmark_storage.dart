import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

class BookmarkStorage {
  static const _key = 'bookmarked_posts';

  static Future<List<int>> getBookmarkedIds() async {
    final sp = await SharedPreferences.getInstance();
    final jsonStr = sp.getString(_key);
    if (jsonStr == null) return [];
    final List<dynamic> ids = json.decode(jsonStr);
    return ids.cast<int>();
  }

  static Future<void> saveBookmarkedIds(List<int> ids) async {
    final sp = await SharedPreferences.getInstance();
    sp.setString(_key, json.encode(ids));
  }
}
