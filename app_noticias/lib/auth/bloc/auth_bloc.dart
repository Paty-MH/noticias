import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(const AuthInitial()) {
    on<AppStarted>(_onStart);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<UpdateProfileRequested>(_onUpdateProfile);
  }

  /// 🔁 AL INICIAR LA APP
  Future<void> _onStart(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final AppUser? user = await authService.getCurrentUser();

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  /// 🔐 LOGIN
  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final user = await authService.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(const AuthUnauthenticated());
    }
  }

  /// 📝 REGISTRO
  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await authService.register(
        event.name,
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(const AuthUnauthenticated());
    }
  }

  /// 👤 ACTUALIZAR PERFIL (🔥 CLAVE)
  Future<void> _onUpdateProfile(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final updatedUser = await authService.updateProfile(
        name: event.name,
        phone: event.phone,
        imageUrl: event.imageUrl,
      );

      /// ✅ UN SOLO ESTADO
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// 🚪 LOGOUT
  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await authService.logout();
    emit(const AuthUnauthenticated());
  }
}
