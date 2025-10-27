import '../models/expense.dart';
import '../models/category.dart';

class ExpenseManager {
  /// Total per kategori berbasis ID kategori (tanpa butuh list kategori).
  static Map<String, double> totalByCategoryId(List<Expense> expenses) {
    final m = <String, double>{};
    for (final e in expenses) {
      m[e.categoryId] = (m[e.categoryId] ?? 0) + e.amount;
    }
    return m;
  }

  /// Total per kategori berbasis NAMA kategori.
  /// Sediakan peta kategori: categoryId -> CategoryModel, agar bisa resolve nama.
  static Map<String, double> totalByCategoryName(
    List<Expense> expenses,
    Map<String, CategoryModel> categoriesById,
  ) {
    final m = <String, double>{};
    for (final e in expenses) {
      final name = categoriesById[e.categoryId]?.name ?? 'Lainnya';
      m[name] = (m[name] ?? 0) + e.amount;
    }
    return m;
  }

  /// Pengeluaran dengan nominal terbesar (null jika kosong)
  static Expense? highest(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => a.amount >= b.amount ? a : b);
  }

  /// Filter berdasarkan bulan & tahun
  static List<Expense> byMonth(
    List<Expense> expenses, {
    required int month,
    required int year,
  }) {
    return expenses
        .where((e) => e.date.month == month && e.date.year == year)
        .toList();
  }

  /// Pencarian: judul, deskripsi, dan (opsional) nama kategori.
  /// Jika [categoriesById] disediakan, kita ikut cari di nama kategori.
  static List<Expense> search(
    List<Expense> expenses,
    String keyword, {
    Map<String, CategoryModel>? categoriesById,
  }) {
    final q = keyword.trim().toLowerCase();
    if (q.isEmpty) return expenses;

    return expenses.where((e) {
      final inTitle = e.title.toLowerCase().contains(q);
      final inDesc = (e.description ?? '').toLowerCase().contains(q);
      final inCat =
          categoriesById == null
              ? false
              : (categoriesById[e.categoryId]?.name.toLowerCase().contains(q) ??
                  false);
      return inTitle || inDesc || inCat;
    }).toList();
  }

  /// Rata-rata pengeluaran per hari unik dalam list
  static double averageDaily(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    final total = expenses.fold<double>(0, (s, e) => s + e.amount);
    final uniqueDays =
        expenses
            .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
            .toSet()
            .length;
    return uniqueDays == 0 ? 0 : total / uniqueDays;
  }

  /// Total per bulan (YYYY-MM -> total) — berguna untuk grafik tren
  static Map<String, double> monthlyTotals(List<Expense> expenses) {
    final m = <String, double>{};
    for (final e in expenses) {
      final key = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
      m[key] = (m[key] ?? 0) + e.amount;
    }
    return m;
  }

  /// Sort utility (default: tanggal terbaru dulu)
  static List<Expense> sortByDateDesc(List<Expense> expenses) {
    final list = [...expenses];
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}
