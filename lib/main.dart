import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/auth_service.dart';

// Import semua screen
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/advanced_expense_list_screen.dart';
import 'screens/looping_screen.dart';
import 'screens/add_edit_expense_screen.dart';
import 'screens/category_screen.dart';
import 'screens/statistics_screen.dart';

/// 🔹 Konsistensi route
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String expenses = '/expenses';
  static const String expensesAdvanced = '/expenses-advanced';
  static const String looping = '/looping';
  static const String addExpense = '/expense-add';
  static const String categories = '/categories';
  static const String statistics = '/statistics';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Init Hive untuk data lokal (tanpa Firebase)
  await Hive.initFlutter();
  await Hive.openBox('expenses'); // dipakai ExpenseService
  await Hive.openBox('categories'); // dipakai CategoryService

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multi-User Expense App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // 🔹 Wallpaper gradient global (punyamu tetap dipakai)
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF74ABE2), Color(0xFF5563DE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
            if (child != null) child,
          ],
        );
      },

      // 🔹 Auto-login: jika masih ada sesi → langsung Home, kalau tidak → Login
      home: FutureBuilder(
        future: AuthService().currentUser(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.data != null) {
            return const HomeScreen(); // user masih login
          }
          return const LoginScreen(); // belum login
        },
      ),

      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
        AppRoutes.expenses: (_) => const ExpenseScreen(),
        AppRoutes.expensesAdvanced: (_) => const AdvancedExpenseListScreen(),
        AppRoutes.looping: (_) => const LoopingScreen(),
        AppRoutes.addExpense: (_) => const AddEditExpenseScreen(),
        AppRoutes.categories: (_) => const CategoryScreen(),
        AppRoutes.statistics: (_) => const StatisticsScreen(),
      },
    );
  }
}
