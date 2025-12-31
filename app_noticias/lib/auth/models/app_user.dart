import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String imageUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });

  /// 🔄 COPY
  AppUser copyWith({String? name, String? phone, String? imageUrl}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// 🔥 FROM FIRESTORE
  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      id: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }

  /// 💾 TO FIRESTORE
  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'phone': phone, 'imageUrl': imageUrl};
  }

  @override
  List<Object?> get props => [id, name, email, phone, imageUrl];
}
