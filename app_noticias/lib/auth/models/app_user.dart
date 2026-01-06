import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String imageUrl;
  final bool isGuest;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
    this.isGuest = false,
  });

  AppUser copyWith({
    String? name,
    String? phone,
    String? imageUrl,
    bool? isGuest,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      id: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isGuest: false,
    );
  }

  factory AppUser.guest() {
    return const AppUser(
      id: 'guest',
      name: 'Invitado',
      email: '',
      phone: '',
      imageUrl: '',
      isGuest: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, email, phone, imageUrl, isGuest];
}
