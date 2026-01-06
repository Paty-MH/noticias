import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 🔁 USUARIO ACTUAL
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
          email: email, password: password);
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists) throw Exception('Usuario no encontrado');
      return AppUser.fromFirestore(cred.user!.uid, doc.data()!);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw Exception('Contraseña incorrecta');
        case 'user-not-found':
          throw Exception('No existe una cuenta con este correo');
        case 'invalid-email':
          throw Exception('Correo inválido');
        default:
          throw Exception('Error al iniciar sesión');
      }
    }
  }

  /// 📝 REGISTER
  Future<AppUser> register(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = AppUser(
        id: cred.user!.uid,
        name: name,
        email: email,
        phone: '',
        imageUrl: '',
      );
      await _db.collection('users').doc(user.id).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Este correo ya está registrado');
        case 'weak-password':
          throw Exception('La contraseña es muy débil');
        default:
          throw Exception('Error al registrar usuario');
      }
    }
  }

  /// ✏️ UPDATE PROFILE (ahora soporta imageFile)
  Future<AppUser> updateProfile({
    required String name,
    required String phone,
    required String imageUrl,
    File? imageFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    String finalImageUrl = imageUrl;

    // 🔥 Si envían imageFile, subimos a Firebase Storage
    if (imageFile != null) {
      finalImageUrl = await uploadProfileImage(imageFile);
    }

    await _db.collection('users').doc(user.uid).update({
      'name': name,
      'phone': phone,
      'imageUrl': finalImageUrl,
    });

    final doc = await _db.collection('users').doc(user.uid).get();
    return AppUser.fromFirestore(user.uid, doc.data()!);
  }

  /// 📤 SUBIR IMAGEN DE PERFIL
  Future<String> uploadProfileImage(File image) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
    final extension = p.extension(image.path);

    final ref = _storage.ref().child('profile_images/${user.uid}$extension');
    final metadata = SettableMetadata(contentType: mimeType);

    await ref.putFile(image, metadata);
    return await ref.getDownloadURL();
  }

  /// 🗑️ DELETE ACCOUNT
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final imageUrl = doc.data()?['imageUrl'] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await _storage.refFromURL(imageUrl).delete();
        }
      }

      await _db.collection('users').doc(user.uid).delete();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Vuelve a iniciar sesión para eliminar tu cuenta');
      } else {
        throw Exception('No se pudo eliminar la cuenta');
      }
    }
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
