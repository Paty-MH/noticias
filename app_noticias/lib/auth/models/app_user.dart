class AppUser {
  final String id;
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

  // 🔁 COPY WITH (perfil)
  AppUser copyWith({String? name, String? phone, String? imageUrl}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // 📦 FROM JSON (leer de storage / backend)
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  // 📤 TO JSON (guardar en storage / backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
    };
  }
}
