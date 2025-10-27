import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // ⬅️ ambil user aktif (lokal)
import '../services/expense_service.dart'; // ⬅️ Hive service
import '../models/expense.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final srv = ExpenseService();

    return FutureBuilder(
      future: AuthService().currentUser(), // ambil user aktif
      builder: (context, snapUser) {
        if (snapUser.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapUser.data;
        final uid = user?.uid;

        if (uid == null) {
          return const Scaffold(
            body: Center(child: Text('Silakan login terlebih dahulu.')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Expenses')),
          body: StreamBuilder<List<Expense>>(
            stream: srv.watchForUser(uid), // ⬅️ realtime lokal dari Hive
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('Gagal memuat: ${snap.error}'));
              }

              final expenses = snap.data ?? [];
              if (expenses.isEmpty) {
                return const Center(child: Text('Belum ada data'));
              }

              return ListView.separated(
                itemCount: expenses.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final e = expenses[i];
                  final dateStr =
                      '${e.date.day.toString().padLeft(2, '0')}-'
                      '${e.date.month.toString().padLeft(2, '0')}-'
                      '${e.date.year}';

                  return ListTile(
                    title: Text(e.title),
                    subtitle: Text('$dateStr • ${e.categoryId}'),
                    trailing: Text('Rp ${e.amount.toStringAsFixed(0)}'),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
