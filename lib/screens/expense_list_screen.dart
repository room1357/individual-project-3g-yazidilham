import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final srv = ExpenseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: StreamBuilder<List<Expense>>(
        stream: srv.streamForUser(uid),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final expenses = snap.data!;
          if (expenses.isEmpty)
            return const Center(child: Text('Belum ada data'));
          return ListView.separated(
            itemCount: expenses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final e = expenses[i];
              return ListTile(
                title: Text(e.title),
                subtitle: Text('${e.date.toLocal()} • ${e.categoryId}'),
                trailing: Text('Rp ${e.amount.toStringAsFixed(0)}'),
              );
            },
          );
        },
      ),
    );
  }
}
