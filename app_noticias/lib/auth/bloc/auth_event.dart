import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginRequested extends AuthEvent {
  final String email, password;
  const LoginRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name, email, password;
  const RegisterRequested(this.name, this.email, this.password);
  @override
  List<Object?> get props => [name, email, password];
}

class UpdateProfileRequested extends AuthEvent {
  final String name, phone, imageUrl;
  const UpdateProfileRequested({
    required this.name,
    required this.phone,
    required this.imageUrl,
  });
  @override
  List<Object?> get props => [name, phone, imageUrl];
}

class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
