import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserService {
  static const String _keyUid = 'user_uid';
  static const String _keyEmail = 'user_email';
  static const String _keyUsername = 'user_username';
  static const String _keyFullName = 'user_fullname';
  static const String _keyPhotoUrl = 'user_photo';

  /// 🔹 Simpan profil user ke penyimpanan lokal
  Future<void> saveProfile(UserProfile profile) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyUid, profile.uid);
    await sp.setString(_keyEmail, profile.email);
    await sp.setString(_keyUsername, profile.username);
    await sp.setString(_keyFullName, profile.fullName);
    await sp.setString(_keyPhotoUrl, profile.photoUrl ?? '');
  }

  /// 🔹 Ambil profil user berdasarkan UID
  Future<UserProfile?> fetchProfile(String uid) async {
    final sp = await SharedPreferences.getInstance();
    final savedUid = sp.getString(_keyUid);
    if (savedUid != uid) return null;

    final email = sp.getString(_keyEmail);
    final username = sp.getString(_keyUsername);
    final fullName = sp.getString(_keyFullName);
    final photo = sp.getString(_keyPhotoUrl);

    if (email == null) return null;

    return UserProfile(
      uid: savedUid ?? '',
      email: email,
      username: username ?? '',
      fullName: fullName ?? '',
      photoUrl: photo,
    );
  }

  /// 🔹 Ambil profil berdasarkan username (opsional)
  Future<UserProfile?> fetchProfileByUsername(String username) async {
    final sp = await SharedPreferences.getInstance();
    final savedUsername = sp.getString(_keyUsername);
    if (savedUsername == null ||
        savedUsername.toLowerCase() != username.toLowerCase()) {
      return null;
    }

    final uid = sp.getString(_keyUid) ?? '';
    final email = sp.getString(_keyEmail) ?? '';
    final fullName = sp.getString(_keyFullName) ?? '';
    final photo = sp.getString(_keyPhotoUrl);

    return UserProfile(
      uid: uid,
      email: email,
      username: savedUsername,
      fullName: fullName,
      photoUrl: photo,
    );
  }
}
