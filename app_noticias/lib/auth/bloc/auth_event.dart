abstract class AuthEvent {}

// App start
class AppStarted extends AuthEvent {}

// Login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);
}

// Register
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  RegisterRequested(this.name, this.email, this.password);
}

// Logout
class LogoutRequested extends AuthEvent {}

// ✅ UPDATE PROFILE (ESTE FALTABA)
class UpdateProfileRequested extends AuthEvent {
  final String name;
  final String phone;
  final String imageUrl;

  UpdateProfileRequested({
    required this.name,
    required this.phone,
    required this.imageUrl,
  });
}
