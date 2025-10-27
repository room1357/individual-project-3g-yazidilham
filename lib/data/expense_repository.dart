import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import '../models/category.dart'; // berisi CategoryModel

/// Repository sederhana berbasis SharedPreferences (lokal)
class ExpenseRepository {
  ExpenseRepository._();
  static final ExpenseRepository I = ExpenseRepository._();

  static const String _kExpenses = 'expenses_v1';
  static const String _kCategories = 'categories_v1';

  List<Expense> _expenses = [];
  List<CategoryModel> _categories = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<CategoryModel> get categories => List.unmodifiable(_categories);

  // ------------------------------------------------------------
  // Init (load dari SharedPreferences) + seeding kategori awal
  // ------------------------------------------------------------
  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();

    // --- Categories ---
    final rawCat = sp.getString(_kCategories);
    if (rawCat == null) {
      // seed default categories (sertakan 'cat_other' untuk fallback)
      _categories = [
        CategoryModel(id: 'cat_food', name: 'Makanan'),
        CategoryModel(id: 'cat_transport', name: 'Transportasi'),
        CategoryModel(id: 'cat_util', name: 'Utilitas'),
        CategoryModel(id: 'cat_fun', name: 'Hiburan'),
        CategoryModel(id: 'cat_edu', name: 'Pendidikan'),
        CategoryModel(id: 'cat_other', name: 'Lainnya'),
      ];
      await sp.setString(
        _kCategories,
        jsonEncode(_categories.map((e) => e.toJson()).toList()),
      );
    } else {
      final List<dynamic> list = jsonDecode(rawCat) as List<dynamic>;
      _categories =
          list
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList();

      // pastikan ada fallback 'cat_other'
      if (_categories.indexWhere((c) => c.id == 'cat_other') == -1) {
        _categories.add(CategoryModel(id: 'cat_other', name: 'Lainnya'));
        await _saveAll();
      }
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

  // -------------------------
  // Expense CRUD
  // -------------------------
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

  // -------------------------
  // Category CRUD
  // -------------------------
  Future<void> addCategory(CategoryModel c) async {
    // hindari duplikasi id
    if (_categories.any((x) => x.id == c.id)) return;
    _categories.add(c);
    await _saveAll();
  }

  Future<void> renameCategory(String id, String newName) async {
    final idx = _categories.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _categories[idx] = CategoryModel(id: _categories[idx].id, name: newName);
      await _saveAll(); // ⬅️ tadinya kelupaan
    }
  }

  Future<void> deleteCategory(String id) async {
    // jangan izinkan menghapus fallback
    if (id == 'cat_other') return;

    // siapkan fallback
    CategoryModel fallback = CategoryModel(id: 'cat_other', name: 'Lainnya');
    final fIdx = _categories.indexWhere((c) => c.id == fallback.id);
    if (fIdx == -1) {
      _categories.add(fallback);
    } else {
      fallback = _categories[fIdx];
    }

    // remap semua expense yang pakai kategori ini ke fallback
    _expenses =
        _expenses
            .map(
              (e) =>
                  e.categoryId == id ? e.copyWith(categoryId: fallback.id) : e,
            )
            .toList();

    // hapus kategori
    _categories.removeWhere((c) => c.id == id);

    await _saveAll();
  }

  // -------------------------
  // Helpers & Aggregations
  // -------------------------
  String categoryName(String categoryId) {
    return _categories
        .firstWhere(
          (c) => c.id == categoryId,
          orElse: () => CategoryModel(id: 'cat_other', name: 'Lainnya'),
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
