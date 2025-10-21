import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserService {
  static const String _keyUsername = 'user_username';
  static const String _keyFullName = 'user_fullname';

  Future<void> saveProfile(UserProfile profile) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyUsername, profile.username);
    await sp.setString(_keyFullName, profile.fullName);
  }

  Future<UserProfile?> fetchProfile() async {
    final sp = await SharedPreferences.getInstance();
    final username = sp.getString(_keyUsername);
    final fullName = sp.getString(_keyFullName);
    final email = sp.getString('user_email');

    if (username == null || email == null) return null;

    return UserProfile(
      uid: 'local-user',
      email: email,
      username: username,
      fullName: fullName ?? '',
    );
  }

  Future<UserProfile?> fetchProfileByUsername(String username) async {
    final profile = await fetchProfile();
    if (profile != null && profile.username == username) {
      return profile;
    }
    return null;
  }
}
