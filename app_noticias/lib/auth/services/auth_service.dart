import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class AuthService {
  static const _userKey = 'logged_user';

  // 🔁 Obtener sesión activa
  Future<AppUser?> getCurrentUser() async {
    final sp = await SharedPreferences.getInstance();
    final jsonStr = sp.getString(_userKey);
    if (jsonStr == null) return null;
    return AppUser.fromJson(jsonDecode(jsonStr));
  }

  // 📝 REGISTRO
  Future<AppUser> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Todos los campos son obligatorios');
    }

    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: '',
      imageUrl: '',
    );

    final sp = await SharedPreferences.getInstance();
    await sp.setString(_userKey, jsonEncode(user.toJson()));

    return user;
  }

  // 🔐 LOGIN
  Future<AppUser> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Campos obligatorios');
    }

    final sp = await SharedPreferences.getInstance();
    final jsonStr = sp.getString(_userKey);

    if (jsonStr == null) {
      throw Exception('Usuario no registrado');
    }

    final user = AppUser.fromJson(jsonDecode(jsonStr));

    if (user.email != email) {
      throw Exception('Usuario o contraseña incorrectos');
    }

    return user;
  }

  // 👤 PERFIL → obtener datos
  Future<AppUser> getProfile() async {
    final sp = await SharedPreferences.getInstance();
    final jsonStr = sp.getString(_userKey);

    if (jsonStr == null) {
      throw Exception('No hay sesión activa');
    }

    return AppUser.fromJson(jsonDecode(jsonStr));
  }

  // ✏️ PERFIL → actualizar datos
  Future<AppUser> updateProfile({
    required String name,
    required String phone,
    required String imageUrl,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (name.isEmpty) {
      throw Exception('El nombre es obligatorio');
    }

    final sp = await SharedPreferences.getInstance();
    final jsonStr = sp.getString(_userKey);

    if (jsonStr == null) {
      throw Exception('No hay sesión activa');
    }

    final currentUser = AppUser.fromJson(jsonDecode(jsonStr));

    final updatedUser = currentUser.copyWith(
      name: name,
      phone: phone,
      imageUrl: imageUrl,
    );

    await sp.setString(_userKey, jsonEncode(updatedUser.toJson()));

    return updatedUser;
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_userKey);
  }
}
