import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileImageService {
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  Future<String> uploadProfileImage(File image) async {
    final uid = _auth.currentUser!.uid;

    final ref = _storage.ref().child('profile_images/$uid.jpg');

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }
}
