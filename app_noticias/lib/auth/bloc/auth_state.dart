import 'package:equatable/equatable.dart';
import '../models/app_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  final bool isGuest;

  const AuthAuthenticated(
    this.user, {
    this.isGuest = false,
  });

  @override
  List<Object?> get props => [user, isGuest];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 🔹 ESTADO NUEVO: USUARIO NO AUTENTICADO
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
