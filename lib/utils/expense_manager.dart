import '../models/expense.dart';

class ExpenseManager {
  static List<Expense> expenses = [
    Expense(
      id: 'e1',
      title: 'Makan Siang',
      description: 'Nasi goreng dan teh manis',
      categoryId: 'Makanan',
      amount: 25000,
      date: DateTime(2025, 10, 1),
    ),
    Expense(
      id: 'e2',
      title: 'Transportasi',
      description: 'Naik ojek ke kampus',
      categoryId: 'Transportasi',
      amount: 10000,
      date: DateTime(2025, 10, 1),
    ),
    Expense(
      id: 'e3',
      title: 'Kopi',
      description: 'Ngopi sore di kafe',
      categoryId: 'Makanan',
      amount: 20000,
      date: DateTime(2025, 10, 2),
    ),
    Expense(
      id: 'e4',
      title: 'Beli Buku',
      description: 'Buku pemrograman mobile',
      categoryId: 'Edukasi',
      amount: 85000,
      date: DateTime(2025, 9, 29),
    ),
  ];

  static Map<String, double> getTotalByCategory(List<Expense> expenses) {
    final result = <String, double>{};
    for (final e in expenses) {
      result[e.categoryId] = (result[e.categoryId] ?? 0) + e.amount;
    }
    return result;
  }

  static Expense? getHighestExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  static List<Expense> getExpensesByMonth(
    List<Expense> expenses,
    int month,
    int year,
  ) {
    return expenses
        .where((e) => e.date.month == month && e.date.year == year)
        .toList();
  }

  static List<Expense> searchExpenses(List<Expense> expenses, String keyword) {
    final q = keyword.toLowerCase();
    return expenses
        .where(
          (e) =>
              e.title.toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q) ||
              e.categoryId.toLowerCase().contains(q),
        )
        .toList();
  }

  static double getAverageDailyExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final uniqueDays =
        expenses
            .map((e) => '${e.date.year}-${e.date.month}-${e.date.day}')
            .toSet();
    return total / uniqueDays.length;
  }
}
