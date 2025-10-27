import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthService {
  // Data akun (disimpan permanen)
  static const _keyUid = 'user_uid';
  static const _keyEmail = 'user_email';
  static const _keyPassword = 'user_password';
  static const _keyUsername = 'user_username';
  static const _keyFullName = 'user_fullname';

  // Data akun kedua (dummy ke-2)
  static const _keyUid2 = 'user2_uid';
  static const _keyEmail2 = 'user2_email';
  static const _keyPassword2 = 'user2_password';
  static const _keyUsername2 = 'user2_username';
  static const _keyFullName2 = 'user2_fullname';

  // Status sesi login
  static const _keySessionUid = 'session_uid';

  // ======================================================
  // ✅ Tambah dua user dummy
  // ======================================================
  Future<void> addDummyUsers() async {
    final sp = await SharedPreferences.getInstance();

    // 🔹 Dummy pertama
    final existing1 = sp.getString(_keyEmail);
    if (existing1 == null) {
      await sp.setString(_keyUid, 'dummy-001');
      await sp.setString(_keyEmail, 'budi@gmail.com');
      await sp.setString(_keyPassword, 'password123');
      await sp.setString(_keyUsername, 'budi');
      await sp.setString(_keyFullName, 'Budi Santoso');
      print('🌱 Dummy 1 dibuat: budi@gmail.com / password123');
    }

    // 🔹 Dummy kedua
    final existing2 = sp.getString(_keyEmail2);
    if (existing2 == null) {
      await sp.setString(_keyUid2, 'dummy-002');
      await sp.setString(_keyEmail2, 'siti@gmail.com');
      await sp.setString(_keyPassword2, 'rahasia456');
      await sp.setString(_keyUsername2, 'siti');
      await sp.setString(_keyFullName2, 'Siti Aminah');
      print('🌱 Dummy 2 dibuat: siti@gmail.com / rahasia456');
    }
  }

  // ======================================================
  // REGISTER user baru (manual)
  // ======================================================
  Future<UserProfile?> register(
    String email,
    String password,
    String username,
    String fullName,
  ) async {
    final sp = await SharedPreferences.getInstance();

    // Cegah duplikasi sederhana
    final existingEmail = sp.getString(_keyEmail);
    final existingEmail2 = sp.getString(_keyEmail2);
    if (email.trim() == existingEmail || email.trim() == existingEmail2) {
      throw Exception('Email sudah terdaftar.');
    }

    // Simpan data akun baru
    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    await sp.setString(_keyUid, uid);
    await sp.setString(_keyEmail, email.trim());
    await sp.setString(_keyPassword, password.trim());
    await sp.setString(_keyUsername, username.trim());
    await sp.setString(_keyFullName, fullName.trim());
    await sp.setString(_keySessionUid, uid);

    return UserProfile(
      uid: uid,
      email: email.trim(),
      username: username.trim(),
      fullName: fullName.trim(),
    );
  }

  // ======================================================
  // LOGIN user (cek dummy 1, dummy 2, atau hasil register)
  // ======================================================
  Future<UserProfile?> login(String email, String password) async {
    final sp = await SharedPreferences.getInstance();

    final email1 = sp.getString(_keyEmail);
    final pass1 = sp.getString(_keyPassword);
    final uid1 = sp.getString(_keyUid);
    final user1 = sp.getString(_keyUsername);
    final name1 = sp.getString(_keyFullName);

    final email2 = sp.getString(_keyEmail2);
    final pass2 = sp.getString(_keyPassword2);
    final uid2 = sp.getString(_keyUid2);
    final user2 = sp.getString(_keyUsername2);
    final name2 = sp.getString(_keyFullName2);

    // 🔹 cek dummy pertama
    if (email.trim() == email1 && password.trim() == pass1) {
      await sp.setString(_keySessionUid, uid1 ?? 'dummy-001');
      return UserProfile(
        uid: uid1 ?? 'dummy-001',
        email: email1 ?? '',
        username: user1 ?? '',
        fullName: name1 ?? '',
      );
    }

    // 🔹 cek dummy kedua
    if (email.trim() == email2 && password.trim() == pass2) {
      await sp.setString(_keySessionUid, uid2 ?? 'dummy-002');
      return UserProfile(
        uid: uid2 ?? 'dummy-002',
        email: email2 ?? '',
        username: user2 ?? '',
        fullName: name2 ?? '',
      );
    }

    throw Exception('Email atau password salah.');
  }

  // ======================================================
  // LOGOUT
  // ======================================================
  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_keySessionUid);
  }

  // ======================================================
  // AMBIL USER YANG SEDANG LOGIN
  // ======================================================
  Future<UserProfile?> currentUser() async {
    final sp = await SharedPreferences.getInstance();
    final uid = sp.getString(_keySessionUid);
    if (uid == null) return null;

    // cek uid cocok dummy1/dummy2
    if (uid == 'dummy-001') {
      return UserProfile(
        uid: uid,
        email: sp.getString(_keyEmail) ?? '',
        username: sp.getString(_keyUsername) ?? '',
        fullName: sp.getString(_keyFullName) ?? '',
      );
    }
    if (uid == 'dummy-002') {
      return UserProfile(
        uid: uid,
        email: sp.getString(_keyEmail2) ?? '',
        username: sp.getString(_keyUsername2) ?? '',
        fullName: sp.getString(_keyFullName2) ?? '',
      );
    }

    // fallback jika hasil register manual
    final email = sp.getString(_keyEmail);
    final username = sp.getString(_keyUsername);
    final fullname = sp.getString(_keyFullName);
    if (email == null) return null;

    return UserProfile(
      uid: uid,
      email: email,
      username: username ?? '',
      fullName: fullname ?? '',
    );
  }

  // ======================================================
  // CEK LOGIN
  // ======================================================
  Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return sp.containsKey(_keySessionUid);
  }
}
