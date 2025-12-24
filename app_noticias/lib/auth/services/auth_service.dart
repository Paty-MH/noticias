import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔁 SESIÓN ACTIVA
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromFirestore(user.uid, doc.data()!);
  }

  /// 🔐 LOGIN
  Future<AppUser> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user!;
      final doc = await _db.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        throw Exception('Usuario no encontrado en la base de datos');
      }

      return AppUser.fromFirestore(user.uid, doc.data()!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No existe una cuenta con este correo');
      } else if (e.code == 'wrong-password') {
        throw Exception('Contraseña incorrecta');
      } else if (e.code == 'invalid-email') {
        throw Exception('Correo inválido');
      } else {
        throw Exception('Error al iniciar sesión');
      }
    }
  }

  /// 📝 REGISTER
  Future<AppUser> register(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user!;

      final appUser = AppUser(
        id: user.uid,
        name: name,
        email: email,
        phone: '',
        imageUrl: '',
      );

      await _db.collection('users').doc(user.uid).set(appUser.toMap());

      return appUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Este correo ya está registrado');
      } else if (e.code == 'weak-password') {
        throw Exception('La contraseña es muy débil');
      } else if (e.code == 'invalid-email') {
        throw Exception('El correo no es válido');
      } else {
        throw Exception('Error al registrar usuario');
      }
    }
  }

  /// ✏️ UPDATE PROFILE
  Future<AppUser> updateProfile({
    required String name,
    required String phone,
    required String imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay sesión activa');
    }

    await _db.collection('users').doc(user.uid).update({
      'name': name,
      'phone': phone,
      'imageUrl': imageUrl,
    });

    final updatedDoc = await _db.collection('users').doc(user.uid).get();

    return AppUser.fromFirestore(user.uid, updatedDoc.data()!);
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
