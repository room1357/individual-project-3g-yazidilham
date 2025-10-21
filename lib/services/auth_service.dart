import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthService {
  static const String _keyEmail = 'user_email';
  static const String _keyPassword = 'user_password';
  static const String _keyUsername = 'user_username';
  static const String _keyFullName = 'user_fullname';

  // Register user baru
  Future<UserProfile?> register(
    String email,
    String password,
    String username,
    String fullName,
  ) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyEmail, email);
    await sp.setString(_keyPassword, password);
    await sp.setString(_keyUsername, username);
    await sp.setString(_keyFullName, fullName);

    return UserProfile(
      uid: 'local-user',
      email: email,
      username: username,
      fullName: fullName,
    );
  }

  // Login user
  Future<UserProfile?> login(String email, String password) async {
    final sp = await SharedPreferences.getInstance();
    final savedEmail = sp.getString(_keyEmail);
    final savedPass = sp.getString(_keyPassword);
    final savedUser = sp.getString(_keyUsername);
    final savedName = sp.getString(_keyFullName);

    if (savedEmail == email && savedPass == password) {
      return UserProfile(
        uid: 'local-user',
        email: savedEmail!,
        username: savedUser ?? 'user',
        fullName: savedName ?? 'Pengguna Lokal',
      );
    }
    return null;
  }

  // Logout user
  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear(); // hapus semua data user
  }
}
