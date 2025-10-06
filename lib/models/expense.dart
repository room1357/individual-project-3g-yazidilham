class Expense {
  String title;
  String description;
  String category;
  double amount;
  DateTime date;

  Expense({
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });
}

class ExpenseManager {
  static List<Expense> expenses = [
    Expense(
      title: 'Makan Siang',
      description: 'Nasi goreng dan teh manis',
      category: 'Makanan',
      amount: 25000,
      date: DateTime(2025, 10, 1),
    ),
    Expense(
      title: 'Transportasi',
      description: 'Naik ojek ke kampus',
      category: 'Transportasi',
      amount: 10000,
      date: DateTime(2025, 10, 1),
    ),
    Expense(
      title: 'Kopi',
      description: 'Ngopi sore di kafe',
      category: 'Makanan',
      amount: 20000,
      date: DateTime(2025, 10, 2),
    ),
    Expense(
      title: 'Beli Buku',
      description: 'Buku pemrograman mobile',
      category: 'Edukasi',
      amount: 85000,
      date: DateTime(2025, 9, 29),
    ),
  ];

  static Map<String, double> getTotalByCategory(List<Expense> expenses) {
    Map<String, double> result = {};
    for (var expense in expenses) {
      result[expense.category] =
          (result[expense.category] ?? 0) + expense.amount;
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
        .where(
          (expense) => expense.date.month == month && expense.date.year == year,
        )
        .toList();
  }

  static List<Expense> searchExpenses(List<Expense> expenses, String keyword) {
    String lowerKeyword = keyword.toLowerCase();
    return expenses
        .where(
          (expense) =>
              expense.title.toLowerCase().contains(lowerKeyword) ||
              expense.description.toLowerCase().contains(lowerKeyword) ||
              expense.category.toLowerCase().contains(lowerKeyword),
        )
        .toList();
  }

  static double getAverageDaily(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;

    double total = expenses.fold(0, (sum, expense) => sum + expense.amount);

    Set<String> uniqueDays =
        expenses
            .map(
              (expense) =>
                  '${expense.date.year}-${expense.date.month}-${expense.date.day}',
            )
            .toSet();

    return total / uniqueDays.length;
  }
}
