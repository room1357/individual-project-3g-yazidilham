import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 🔹 Ambil data dari SharedPreferences
  Future<void> _loadProfile() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      fullNameController.text = sp.getString("profile_fullname") ?? "";
      usernameController.text = sp.getString("profile_username") ?? "";
      emailController.text = sp.getString("profile_email") ?? "";
      bioController.text = sp.getString("profile_bio") ?? "";
    });
  }

  // 🔹 Simpan data ke SharedPreferences
  Future<void> _saveProfile() async {
    if (fullNameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty) {
      _snack("Nama Lengkap, Username, dan Email wajib diisi!");
      return;
    }

    setState(() => loading = true);
    final sp = await SharedPreferences.getInstance();
    await sp.setString("profile_fullname", fullNameController.text.trim());
    await sp.setString("profile_username", usernameController.text.trim());
    await sp.setString("profile_email", emailController.text.trim());
    await sp.setString("profile_bio", bioController.text.trim());

    setState(() => loading = false);
    _snack("Profil berhasil disimpan!");
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),

            // Full Name
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Username
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Bio
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Bio / Tentang Saya",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text("Simpan Profil"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
