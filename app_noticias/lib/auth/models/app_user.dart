class AppUser {
  final String id; // 🔑 Firebase UID
  final String name;
  final String email;
  final String phone;
  final String imageUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });

  // 🔁 COPY WITH (editar perfil)
  AppUser copyWith({String? name, String? phone, String? imageUrl}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // 📦 FROM FIRESTORE
  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      id: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // 📤 TO FIRESTORE
  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'phone': phone, 'imageUrl': imageUrl};
  }
}
