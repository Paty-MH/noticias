import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/constants.dart';
import '../models/post_model.dart';

class ApiService {
  final String base = Constants.baseUrl;

  Future<List<Post>> fetchPosts({
    int page = 1,
    int perPage = Constants.perPage,
  }) async {
    final uri = Uri.parse('$base/posts?per_page=$perPage&page=$page&_embed');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> body = json.decode(res.body);
      return body.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching posts: ${res.statusCode}');
    }
  }

  Future<List<Post>> searchPosts(
    String query, {
    int page = 1,
    int perPage = Constants.perPage,
  }) async {
    final uri = Uri.parse(
      '$base/posts?search=${Uri.encodeComponent(query)}&per_page=$perPage&page=$page&_embed',
    );
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> body = json.decode(res.body);
      return body.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Error searching posts: ${res.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final uri = Uri.parse('$base/categories?per_page=100');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> body = json.decode(res.body);
      return body.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error fetching categories: ${res.statusCode}');
    }
  }

  Future<List<Post>> fetchPostsByCategory(
    int categoryId, {
    int page = 1,
    int perPage = Constants.perPage,
  }) async {
    final uri = Uri.parse(
      '$base/posts?categories=$categoryId&per_page=$perPage&page=$page&_embed',
    );
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> body = json.decode(res.body);
      return body.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching posts by category: ${res.statusCode}');
    }
  }
}
