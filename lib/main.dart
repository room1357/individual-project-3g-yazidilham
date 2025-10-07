import 'package:flutter/material.dart';

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

void main() {
  // 👉 Kalau mau test fungsi console dari LoopingExamples
  // import 'utils/looping_examples.dart' lalu pakai:
  // print("Total (for): ${LoopingExamples.calculateTotalTraditional(LoopingExamples.expenses)}");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // opsional
      ),

      // Halaman awal aplikasi
      initialRoute: '/login',

      // Daftar route
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(username: 'User'),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/about': (context) => const AboutScreen(),
        '/expenses': (context) => const ExpenseScreen(),
        '/expenses-advanced': (context) => const AdvancedExpenseListScreen(),
        '/looping': (context) => const LoopingScreen(),
      },
    );
  }
}
