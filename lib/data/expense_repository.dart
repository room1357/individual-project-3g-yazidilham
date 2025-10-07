import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ExpenseRepository {
  ExpenseRepository._();
  static final ExpenseRepository I = ExpenseRepository._();

  static const String _kExpenses = 'expenses_v1';
  static const String _kCategories = 'categories_v1';

  List<Expense> _expenses = [];
  List<Category> _categories = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Category> get categories => List.unmodifiable(_categories);

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();

    // --- Categories ---
    final rawCat = sp.getString(_kCategories);
    if (rawCat == null) {
      // seed default categories
      _categories = [
        Category(id: 'cat_food', name: 'Makanan'),
        Category(id: 'cat_transport', name: 'Transportasi'),
        Category(id: 'cat_util', name: 'Utilitas'),
        Category(id: 'cat_fun', name: 'Hiburan'),
        Category(id: 'cat_edu', name: 'Pendidikan'),
      ];
      await sp.setString(
        _kCategories,
        jsonEncode(_categories.map((e) => e.toJson()).toList()),
      );
    } else {
      final List<dynamic> list = jsonDecode(rawCat) as List<dynamic>;
      _categories =
          list
              .map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    // --- Expenses ---
    final rawExp = sp.getString(_kExpenses);
    if (rawExp == null) {
      _expenses = [];
    } else {
      final List<dynamic> list = jsonDecode(rawExp) as List<dynamic>;
      _expenses =
          list.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _saveAll() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _kExpenses,
      jsonEncode(_expenses.map((e) => e.toJson()).toList()),
    );
    await sp.setString(
      _kCategories,
      jsonEncode(_categories.map((e) => e.toJson()).toList()),
    );
  }

  // ---------- Expense CRUD ----------
  Future<void> addExpense(Expense e) async {
    _expenses.add(e);
    await _saveAll();
  }

  Future<void> updateExpense(Expense e) async {
    final idx = _expenses.indexWhere((x) => x.id == e.id);
    if (idx != -1) {
      _expenses[idx] = e;
      await _saveAll();
    }
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _saveAll();
  }

  // ---------- Category CRUD ----------
  Future<void> addCategory(Category c) async {
    _categories.add(c);
    await _saveAll();
  }

  Future<void> renameCategory(String id, String newName) async {
    final idx = _categories.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _categories[idx] = Category(id: _categories[idx].id, name: newName);
      await _saveAll();
    }
  }

  Future<void> deleteCategory(String id) async {
    // fallback ke "Lainnya" jika kategori dihapus
    final fallback = _categories.firstWhere(
      (c) => c.id == 'cat_other',
      orElse: () {
        final other = Category(id: 'cat_other', name: 'Lainnya');
        _categories.add(other);
        return other;
      },
    );

    _expenses =
        _expenses
            .map(
              (e) =>
                  e.categoryId == id
                      ? Expense(
                        id: e.id,
                        title: e.title,
                        description: e.description,
                        categoryId: fallback.id,
                        amount: e.amount,
                        date: e.date,
                      )
                      : e,
            )
            .toList();

    _categories.removeWhere((c) => c.id == id);
    await _saveAll();
  }

  // ---------- Helpers ----------
  String categoryName(String categoryId) {
    return _categories
        .firstWhere(
          (c) => c.id == categoryId,
          orElse: () => Category(id: 'cat_other', name: 'Lainnya'),
        )
        .name;
  }

  Map<String, double> totalByCategory() {
    final map = <String, double>{};
    for (final e in _expenses) {
      final name = categoryName(e.categoryId);
      map[name] = (map[name] ?? 0) + e.amount;
    }
    return map;
  }
}
