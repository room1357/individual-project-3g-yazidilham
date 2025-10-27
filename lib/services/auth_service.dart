import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthService {
  // Data akun (disimpan permanen)
  static const _keyUid = 'user_uid';
  static const _keyEmail = 'user_email';
  static const _keyPassword = 'user_password';
  static const _keyUsername = 'user_username';
  static const _keyFullName = 'user_fullname';

  // Status sesi login (boleh dihapus saat logout)
  static const _keySessionUid = 'session_uid';

  // REGISTER user baru
  Future<UserProfile?> register(
    String email,
    String password,
    String username,
    String fullName,
  ) async {
    final sp = await SharedPreferences.getInstance();

    // Cegah duplikasi email sederhana (single account)
    final existingEmail = sp.getString(_keyEmail);
    if (existingEmail != null && existingEmail == email.trim()) {
      throw Exception('Email sudah terdaftar.');
    }

    // Simpan data akun
    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    await sp.setString(_keyUid, uid);
    await sp.setString(_keyEmail, email.trim());
    await sp.setString(_keyPassword, password.trim());
    await sp.setString(_keyUsername, username.trim());
    await sp.setString(_keyFullName, fullName.trim());

    // Set sesi login aktif
    await sp.setString(_keySessionUid, uid);

    return UserProfile(
      uid: uid,
      email: email.trim(),
      username: username.trim(),
      fullName: fullName.trim(),
    );
  }

  // LOGIN user (email + password)
  Future<UserProfile?> login(String email, String password) async {
    final sp = await SharedPreferences.getInstance();

    final savedEmail = sp.getString(_keyEmail);
    final savedPass = sp.getString(_keyPassword);
    final savedUser = sp.getString(_keyUsername);
    final savedName = sp.getString(_keyFullName);
    final savedUid = sp.getString(_keyUid);

    if (savedEmail == null || savedPass == null) {
      throw Exception('Belum ada akun terdaftar.');
    }

    if (savedEmail == email.trim() && savedPass == password.trim()) {
      // aktifkan sesi
      await sp.setString(_keySessionUid, savedUid ?? 'local-user');

      return UserProfile(
        uid: savedUid ?? 'local-user',
        email: savedEmail,
        username: savedUser ?? '',
        fullName: savedName ?? '',
      );
    } else {
      throw Exception('Email atau password salah.');
    }
  }

  // LOGOUT (hapus hanya sesi, JANGAN clear semua)
  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_keySessionUid);
  }

  // Ambil user yang sedang login (berdasarkan sesi)
  Future<UserProfile?> currentUser() async {
    final sp = await SharedPreferences.getInstance();
    final sessionUid = sp.getString(_keySessionUid);
    if (sessionUid == null) return null;

    final email = sp.getString(_keyEmail);
    final username = sp.getString(_keyUsername);
    final fullname = sp.getString(_keyFullName);

    if (email == null) return null;

    return UserProfile(
      uid: sessionUid,
      email: email,
      username: username ?? '',
      fullName: fullname ?? '',
    );
  }

  // Cek sedang login (berdasarkan sesi)
  Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return sp.containsKey(_keySessionUid);
  }
}
