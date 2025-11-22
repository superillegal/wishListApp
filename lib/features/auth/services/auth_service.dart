import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  static const _keyUsername = 'auth_username';
  static const _keyPassword = 'auth_password';

  Future<bool> hasAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUsername) && prefs.containsKey(_keyPassword);
  }

  Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString(_keyUsername);
    final savedPass = prefs.getString(_keyPassword);
    return username == savedUser && password == savedPass;
  }

  Future<bool> register(String username, String password) async {
    if (username.trim().isEmpty || password.trim().length < 3) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username.trim());
    await prefs.setString(_keyPassword, password);
    return true;
  }

  Future<void> logout() async {
    // Ничего не стираем, чтобы пользователь мог войти повторно.
  }

  Future<String?> currentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }
}
