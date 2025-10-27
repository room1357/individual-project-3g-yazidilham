import 'package:flutter/material.dart';
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
                        Icons.attach_money,
                        Colors.teal,
                        AppRoutes.expenses,
                      ),
                      _buildDashboardCard(
                        context,
                        'Expenses (Advanced)',
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
                        'Tambah Expense',
                        Icons.add,
                        Colors.green,
                        AppRoutes.addExpense,
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
    String route,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
