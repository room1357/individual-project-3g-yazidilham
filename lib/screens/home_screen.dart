import 'dart:convert'; // ⬅️ tambah
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ⬅️ tambah

import '../services/auth_service.dart';
import '../services/export_service.dart';
import '../models/user_profile.dart';
import '../main.dart'; // AppRoutes

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: AuthService().currentUser(), // ambil user aktif (lokal)
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          // tidak ada sesi -> kirim ke login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (_) => false,
            );
          });
          return const SizedBox.shrink();
        }

        final displayName =
            user.username.isNotEmpty
                ? user.username
                : (user.email.isNotEmpty ? user.email : 'User');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            backgroundColor: Colors.blue,
            actions: [
              IconButton(
                tooltip: 'Export CSV',
                icon: const Icon(Icons.file_download),
                onPressed: () async {
                  await ExportService.shareCsv();
                },
              ),
              IconButton(
                tooltip: 'Logout',
                onPressed: () async {
                  await AuthService().logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (_) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),

          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 38, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome $displayName!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    await AuthService().logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (_) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====== KARTU TOTAL PENGELUARAN (per user) ======
                FutureBuilder<_Totals>(
                  future: _loadTotals(user.uid),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return _TotalCard.skeleton();
                    }
                    final data = snap.data ?? const _Totals(0, 0);
                    return _TotalCard(total: data.total, count: data.count);
                  },
                ),
                const SizedBox(height: 20),

                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildDashboardCard(
                        context,
                        'Profile',
                        Icons.person,
                        Colors.green,
                        AppRoutes.profile,
                      ),
                      _buildDashboardCard(
                        context,
                        'Expenses',
                        Icons.analytics,
                        Colors.indigo,
                        AppRoutes.expensesAdvanced,
                      ),
                      _buildDashboardCard(
                        context,
                        'Help',
                        Icons.help,
                        Colors.red,
                        AppRoutes.about,
                      ),
                      _buildDashboardCard(
                        context,
                        'Kategori',
                        Icons.category,
                        Colors.brown,
                        AppRoutes.categories,
                      ),
                      _buildDashboardCard(
                        context,
                        'Statistik',
                        Icons.pie_chart,
                        Colors.deepPurple,
                        AppRoutes.statistics,
                      ),
                      _buildDashboardCard(
                        context,
                        'Pesan',
                        Icons.message,
                        Colors.orange,
                        AppRoutes.massage,
                      ),
                      _buildDashboardCard(
                        context,
                        'Export',
                        Icons.import_export,
                        Colors.deepOrange,
                        AppRoutes.export,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String? route,
  ) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Halaman "$title" belum tersedia.'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Card(
        color: color.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===== Helper: ambil total & jumlah transaksi dari SharedPreferences (per user)
Future<_Totals> _loadTotals(String uid) async {
  final sp = await SharedPreferences.getInstance();
  final raw = sp.getString('expenses_$uid');
  if (raw == null || raw.isEmpty) return const _Totals(0, 0);

  final List<dynamic> arr = jsonDecode(raw);
  double total = 0;
  for (final e in arr) {
    final amt = (e['amount'] as num?)?.toDouble() ?? 0.0;
    total += amt;
  }
  return _Totals(total, arr.length);
}

class _Totals {
  final double total;
  final int count;
  const _Totals(this.total, this.count);
}

/// ===== Widget kartu total yang rapi
class _TotalCard extends StatelessWidget {
  final double total;
  final int count;
  const _TotalCard({required this.total, required this.count});

  static Widget skeleton() => Container(
    height: 90,
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.all(16),
    child: const Row(
      children: [
        Expanded(child: _ShimmerBox(width: double.infinity, height: 20)),
        SizedBox(width: 16),
        _ShimmerBox(width: 90, height: 32),
      ],
    ),
  );

  String _rp(double v) => 'Rp ${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF74ABE2), Color(0xFF5563DE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Total Pengeluaran',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _rp(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count trx',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
