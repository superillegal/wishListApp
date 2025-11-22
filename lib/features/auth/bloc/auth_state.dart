import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthChecking extends AuthState {
  const AuthChecking();
}

class AuthLogin extends AuthState {
  const AuthLogin();
}

class AuthRegister extends AuthState {
  const AuthRegister();
}

class AuthLoading extends AuthState {
  final bool isLogin;

  const AuthLoading(this.isLogin);

  @override
  List<Object?> get props => [isLogin];
}

class AuthFailure extends AuthState {
  final String message;
  final bool isLogin;

  const AuthFailure(this.message, this.isLogin);

  @override
  List<Object?> get props => [message, isLogin];
}

class Authenticated extends AuthState {
  final String username;

  const Authenticated(this.username);

  @override
  List<Object?> get props => [username];
}
