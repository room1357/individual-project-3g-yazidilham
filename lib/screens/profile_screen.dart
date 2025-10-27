import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // ambil user aktif (lokal)
import '../services/user_service.dart'; // simpan/ambil profil (lokal)
import '../models/user_profile.dart';

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
  final _auth = AuthService();
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Ambil data profil dari storage lokal
  Future<void> _loadProfile() async {
    setState(() => loading = true);
    try {
      // ✅ Ambil user aktif via AuthService lokal (async)
      final current = await _auth.currentUser();
      final uid = current?.uid;

      if (uid == null) {
        _snack('Silakan login terlebih dahulu.', isError: true);
        return;
      }

      final p = await _userService.fetchProfile(uid);
      fullNameController.text = p?.fullName ?? '';
      usernameController.text = p?.username ?? '';
      emailController.text = p?.email ?? '';
      bioController.text = ''; // isi jika kamu menyimpan bio terpisah
    } catch (e) {
      _snack('Gagal memuat profil: $e', isError: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /// Simpan perubahan profil ke storage lokal
  Future<void> _saveProfile() async {
    if (fullNameController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      _snack("Nama Lengkap, Username, dan Email wajib diisi!", isError: true);
      return;
    }

    setState(() => loading = true);
    try {
      // ✅ Ambil user aktif lagi saat simpan
      final current = await _auth.currentUser();
      final uid = current?.uid;

      if (uid == null) {
        _snack('Sesi habis. Silakan login ulang.', isError: true);
        return;
      }

      final profile = UserProfile(
        uid: uid,
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        fullName: fullNameController.text.trim(),
      );

      await _userService.saveProfile(profile);
      _snack("Profil berhasil disimpan!", isError: false);
    } catch (e) {
      _snack("Gagal menyimpan profil: $e", isError: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _snack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.blue.shade700],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar custom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Profil Saya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Isi
              Expanded(
                child:
                    loading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: fullNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Nama Lengkap',
                                        hintText: 'Masukkan nama lengkap',
                                        prefixIcon: Icon(
                                          Icons.badge_outlined,
                                          color: Colors.blue.shade700,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: usernameController,
                                      decoration: InputDecoration(
                                        labelText: 'Username',
                                        hintText: 'Masukkan username',
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: Colors.blue.shade700,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        hintText: 'Masukkan email',
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: Colors.blue.shade700,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: bioController,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        labelText: 'Bio / Tentang Saya',
                                        hintText: 'Ceritakan tentang diri Anda',
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 60,
                                          ),
                                          child: Icon(
                                            Icons.edit_note_outlined,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton.icon(
                                        onPressed: _saveProfile,
                                        icon: const Icon(
                                          Icons.save_outlined,
                                          size: 22,
                                        ),
                                        label: const Text(
                                          'SIMPAN PROFIL',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade700,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
