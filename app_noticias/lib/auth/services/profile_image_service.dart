import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class ProfileImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 📤 SUBIR IMAGEN
  Future<String> uploadProfileImage(File image) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
      final extension = p.extension(image.path);

      final ref = _storage.ref().child('profile_images/${user.uid}$extension');
      final metadata = SettableMetadata(contentType: mimeType);

      await ref.putFile(image, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir imagen de perfil');
    }
  }

  /// 🗑️ ELIMINAR IMAGEN
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;
      await _storage.refFromURL(imageUrl).delete();
    } catch (_) {}
  }
}
