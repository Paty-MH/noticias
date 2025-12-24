import '../models/app_user.dart';

/// Estados base de autenticación
abstract class AuthState {}

/// Estado inicial
class AuthInitial extends AuthState {}

/// Cargando (login, registro, update, etc.)
class AuthLoading extends AuthState {}

/// Usuario autenticado (login / sesión activa)
class AuthAuthenticated extends AuthState {
  final AppUser user;

  AuthAuthenticated(this.user);
}

/// Usuario no autenticado (logout)
class AuthUnauthenticated extends AuthState {}

/// ✅ NUEVO: Perfil actualizado correctamente
class AuthProfileUpdated extends AuthState {
  final AppUser user;

  AuthProfileUpdated(this.user);
}

/// Error general
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
