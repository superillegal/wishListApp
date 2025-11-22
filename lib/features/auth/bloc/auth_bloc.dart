import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/logger_service.dart';
import '../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial()) {
    on<CheckAccount>(_onCheckAccount);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ToggleAuthMode>(_onToggleAuthMode);
  }

  Future<void> _onCheckAccount(
    CheckAccount event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthChecking());
      final hasAccount = await _authService.hasAccount();
      LoggerService.info('AuthBloc: проверка аккаунта -> ${hasAccount ? "есть" : "нет"}');
      emit(hasAccount ? const AuthLogin() : const AuthRegister());
    } catch (e) {
      LoggerService.error('AuthBloc: ошибка проверки $e');
      emit(const AuthRegister());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(true));
      final success = await _authService.login(event.username, event.password);
      if (success) {
        LoggerService.info('AuthBloc: вход ${event.username}');
        emit(Authenticated(event.username));
      } else {
        LoggerService.warning('AuthBloc: неверный логин/пароль ${event.username}');
        emit(const AuthFailure('Неверный логин или пароль', true));
      }
    } catch (e) {
      LoggerService.error('AuthBloc: ошибка входа $e');
      emit(AuthFailure('Не удалось войти: $e', true));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(false));
      final success = await _authService.register(event.username, event.password);
      if (success) {
        LoggerService.info('AuthBloc: регистрация ${event.username}');
        emit(Authenticated(event.username));
      } else {
        emit(const AuthFailure('Введите имя и пароль не короче 3 символов', false));
      }
    } catch (e) {
      LoggerService.error('AuthBloc: ошибка регистрации $e');
      emit(AuthFailure('Не удалось создать аккаунт: $e', false));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout();
    LoggerService.info('AuthBloc: выход');
    emit(const AuthLogin());
  }

  void _onToggleAuthMode(
    ToggleAuthMode event,
    Emitter<AuthState> emit,
  ) {
    final isLogin = state is AuthLogin || (state is AuthFailure && (state as AuthFailure).isLogin);
    emit(isLogin ? const AuthRegister() : const AuthLogin());
  }
}
