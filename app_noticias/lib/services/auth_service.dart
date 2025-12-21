import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/constants.dart';
import '../models/post_model.dart';

class ApiService {
  final String base = Constants.baseUrl;

  // ───────────────── POSTS HOME ─────────────────
  Future<List<Post>> fetchPosts({
    int page = 1,
    int perPage = Constants.perPage,
  }) async {
    final uri = Uri.parse('$base/posts?per_page=$perPage&page=$page&_embed');

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List body = json.decode(res.body);
      return body.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching posts');
    }
  }

  // ───────────────── SEARCH ─────────────────
  Future<List<Post>> searchPosts(
    String query, {
    int page = 1,
    int perPage = Constants.perPage,
  }) async {
    final uri = Uri.parse(
      '$base/posts?search=${Uri.encodeComponent(query)}'
      '&per_page=$perPage&page=$page&_embed',
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List body = json.decode(res.body);
      return body.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Error searching posts');
    }
  }

  // ───────────────── CATEGORIES (FILTRADAS) ─────────────────
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final uri = Uri.parse('$base/categories?per_page=100');

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List body = json.decode(res.body);

      // 🔥 SOLO categorías con noticias
      return body
          .where((e) => e['count'] != null && e['count'] > 0)
          .map<Map<String, dynamic>>(
            (e) => {'id': e['id'], 'name': e['name'], 'count': e['count']},
          )
          .toList();
    } else {
      throw Exception('Error fetching categories');
    }
  }

  // ───────────────── POSTS BY CATEGORY ─────────────────
  Future<List<Post>> fetchPostsByCategory(
    int categoryId, {
    int page = 1,
    int perPage = Constants.perPage,
  }) async {
    final uri = Uri.parse(
      '$base/posts?categories=$categoryId'
      '&per_page=$perPage&page=$page&_embed',
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List body = json.decode(res.body);
      return body.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching posts by category');
    }
  }
}
