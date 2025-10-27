import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/category.dart';

/// Abstraksi penyimpanan. Bisa diganti ke file/SQLite nanti.
abstract class StorageService {
  String? currentUserId;

  Future<List<Expense>> loadExpenses();
  Future<void> saveExpenses(List<Expense> items);

  Future<List<CategoryModel>> loadCategories();
  Future<void> saveCategories(List<CategoryModel> items);
}

/// Implementasi sementara: in-memory
/// Semua user punya daftar expense sendiri (dipisahkan dengan userId).
class InMemoryStorageService implements StorageService {
  @override
  String? currentUserId;

  final Map<String, List<Expense>> _userExpenses = {};
  final Map<String, List<CategoryModel>> _userCategories = {};

  @override
  Future<List<Expense>> loadExpenses() async {
    if (currentUserId == null) return [];
    return Future.value(List.of(_userExpenses[currentUserId!] ?? []));
  }

  @override
  Future<void> saveExpenses(List<Expense> items) async {
    if (currentUserId == null) return;
    _userExpenses[currentUserId!] = List.of(items);
  }

  @override
  Future<List<CategoryModel>> loadCategories() async {
    if (currentUserId == null) return [];
    _userCategories.putIfAbsent(
      currentUserId!,
      () => [
        CategoryModel(id: 'c1', name: 'Makanan'),
        CategoryModel(id: 'c2', name: 'Transportasi'),
        CategoryModel(id: 'c3', name: 'Utilitas'),
        CategoryModel(id: 'c4', name: 'Hiburan'),
        CategoryModel(id: 'c5', name: 'Pendidikan'),
      ],
    );
    return Future.value(List.of(_userCategories[currentUserId!]!));
  }

  @override
  Future<void> saveCategories(List<CategoryModel> items) async {
    if (currentUserId == null) return;
    _userCategories[currentUserId!] = List.of(items);
  }
}

/// Implementasi SharedPreferences (persisten antar restart).
class SharedPreferencesStorageService implements StorageService {
  @override
  String? currentUserId;

  @override
  Future<List<Expense>> loadExpenses() async {
    if (currentUserId == null) return [];
    final prefs = await SharedPreferences.getInstance();
    final key = 'expenses_${currentUserId!}';
    final data = prefs.getString(key);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List;
    return decoded.map((e) => Expense.fromJson(e)).toList();
  }

  @override
  Future<void> saveExpenses(List<Expense> items) async {
    if (currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'expenses_${currentUserId!}';
    final encoded = jsonEncode(
      items.map((e) => e.toJson()).toList(growable: false),
    );
    await prefs.setString(key, encoded);
  }

  @override
  Future<List<CategoryModel>> loadCategories() async {
    if (currentUserId == null) return [];
    final prefs = await SharedPreferences.getInstance();
    final key = 'categories_${currentUserId!}';
    final data = prefs.getString(key);
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      return decoded.map((e) => CategoryModel.fromJson(e)).toList();
    }

    // default jika belum ada
    final defaultCategories = [
      CategoryModel(id: 'c1', name: 'Makanan'),
      CategoryModel(id: 'c2', name: 'Transportasi'),
      CategoryModel(id: 'c3', name: 'Utilitas'),
      CategoryModel(id: 'c4', name: 'Hiburan'),
      CategoryModel(id: 'c5', name: 'Pendidikan'),
    ];
    await saveCategories(defaultCategories);
    return defaultCategories;
  }

  @override
  Future<void> saveCategories(List<CategoryModel> items) async {
    if (currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'categories_${currentUserId!}';
    final encoded = jsonEncode(
      items.map((e) => e.toJson()).toList(growable: false),
    );
    await prefs.setString(key, encoded);
  }
}

/// Manager singleton supaya gampang ganti implementasi
class StorageServiceManager {
  StorageServiceManager._internal();
  static final StorageServiceManager instance =
      StorageServiceManager._internal();

  // Ganti ke InMemoryStorageService() kalau hanya untuk demo/testing
  final StorageService _storage = SharedPreferencesStorageService();

  StorageService get storage => _storage;

  set currentUserId(String? id) {
    _storage.currentUserId = id;
  }
}
