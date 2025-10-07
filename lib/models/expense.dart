class Expense {
  final String id;
  final String title;
  final String description;
  final String category; // bisa diganti enum
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });
}

class ExpenseManager {
  // Data contoh
  static List<Expense> expenses = [
    Expense(
      id: 'e1',
      title: 'Makan Siang',
      description: 'Nasi goreng dan teh manis',
      category: 'Makanan',
      amount: 25000,
      date: DateTime(2025, 10, 1),
    ),
    Expense(
      id: 'e2',
      title: 'Transportasi',
      description: 'Naik ojek ke kampus',
      category: 'Transportasi',
      amount: 10000,
      date: DateTime(2025, 10, 1),
    ),
    Expense(
      id: 'e3',
      title: 'Kopi',
      description: 'Ngopi sore di kafe',
      category: 'Makanan',
      amount: 20000,
      date: DateTime(2025, 10, 2),
    ),
    Expense(
      id: 'e4',
      title: 'Beli Buku',
      description: 'Buku pemrograman mobile',
      category: 'Edukasi',
      amount: 85000,
      date: DateTime(2025, 9, 29),
    ),
  ];

  /// 1. Hitung total per kategori
  static Map<String, double> getTotalByCategory(List<Expense> expenses) {
    final result = <String, double>{};
    for (var expense in expenses) {
      result[expense.category] =
          (result[expense.category] ?? 0) + expense.amount;
    }
    return result;
  }

  /// 2. Ambil pengeluaran tertinggi
  static Expense? getHighestExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  /// 3. Ambil pengeluaran bulan tertentu
  static List<Expense> getExpensesByMonth(
    List<Expense> expenses,
    int month,
    int year,
  ) {
    return expenses
        .where((e) => e.date.month == month && e.date.year == year)
        .toList();
  }

  /// 4. Cari pengeluaran dengan kata kunci
  static List<Expense> searchExpenses(List<Expense> expenses, String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    return expenses.where((e) {
      return e.title.toLowerCase().contains(lowerKeyword) ||
          e.description.toLowerCase().contains(lowerKeyword) ||
          e.category.toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  /// 5. Hitung rata-rata per hari
  static double getAverageDailyExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;

    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

    // Hitung jumlah hari unik
    final uniqueDays =
        expenses
            .map((e) => '${e.date.year}-${e.date.month}-${e.date.day}')
            .toSet();

    return total / uniqueDays.length;
  }
}
