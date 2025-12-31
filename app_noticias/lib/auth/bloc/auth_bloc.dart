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
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<DeleteAccountRequested>(_onDeleteAccount);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onStart(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final user = await authService.getCurrentUser();
      if (user != null)
        emit(AuthAuthenticated(user));
      else
        emit(const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await authService.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_cleanError(e)));
      emit(const AuthUnauthenticated());
    }
  }

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
      emit(AuthError(_cleanError(e)));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authService.updateProfile(
        name: event.name,
        phone: event.phone,
        imageUrl: event.imageUrl,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_cleanError(e)));
      final currentUser = await authService.getCurrentUser();
      if (currentUser != null) emit(AuthAuthenticated(currentUser));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authService.deleteAccount();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(_cleanError(e)));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authService.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(_cleanError(e)));
    }
  }

  String _cleanError(Object e) => e.toString().replaceAll('Exception: ', '');
}
