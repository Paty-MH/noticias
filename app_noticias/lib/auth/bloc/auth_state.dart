import 'package:equatable/equatable.dart';
import '../models/app_user.dart';

/// Estados base de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Cargando (login, registro, update, etc.)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Usuario autenticado (login / sesión activa)
class AuthAuthenticated extends AuthState {
  final AppUser user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Usuario no autenticado (logout)
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// ✅ Perfil actualizado correctamente
class AuthProfileUpdated extends AuthState {
  final AppUser user;

  const AuthProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

/// ❌ Error general
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
