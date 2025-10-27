// lib/services/category_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';

class CategoryService {
  // singleton agar state bertahan
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  final _uuid = const Uuid();

  // ✅ Prefix untuk penyimpanan per-user
  static const String _prefix = 'categories_v1_';

  // (Opsional) sisa variabel lama; aman dibiarkan meski tidak dipakai
  final Map<String, List<CategoryModel>> _byUser = {};
  final Map<String, String> _ownerOf = {};

  // ---------------------------
  // Helpers
  // ---------------------------
  Future<String> _key(String userId) async => '$_prefix$userId';

  Future<void> _saveList(String userId, List<CategoryModel> list) async {
    final sp = await SharedPreferences.getInstance();
    final key = await _key(userId);
    await sp.setString(key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  List<CategoryModel> _seedDefaults() => [
    CategoryModel(id: 'cat_food', name: 'Makanan'),
    CategoryModel(id: 'cat_transport', name: 'Transportasi'),
    CategoryModel(id: 'cat_util', name: 'Utilitas'),
    CategoryModel(id: 'cat_fun', name: 'Hiburan'),
    CategoryModel(id: 'cat_edu', name: 'Pendidikan'),
  ];

  // ---------------------------
  // CRUD
  // ---------------------------

  Future<CategoryModel> create({
    required String userId,
    required String name,
  }) async {
    // Ambil list eksisting (akan auto-seed bila kosong)
    final list = await listByUser(userId);

    // Cegah duplikat nama (case-insensitive)
    final exists = list.any(
      (c) => c.name.toLowerCase() == name.trim().toLowerCase(),
    );
    if (exists) {
      // tetap kembalikan kategori eksisting agar tidak crash
      return list.firstWhere(
        (c) => c.name.toLowerCase() == name.trim().toLowerCase(),
      );
    }

    final id = _uuid.v4();
    final c = CategoryModel(id: id, name: name.trim());
    list.add(c);

    // urutkan by name asc
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    await _saveList(userId, list);
    return c;
  }

  // ✅ HANYA ADA SATU DEFINISI
  Future<List<CategoryModel>> listByUser(String userId) async {
    final sp = await SharedPreferences.getInstance();
    final key = await _key(userId);
    final raw = sp.getString(key);

    List<CategoryModel> list = [];

    if (raw == null || raw.isEmpty) {
      // 🟢 Seed default untuk user baru
      list = _seedDefaults();
      await _saveList(userId, list);
      // print('🌱 Kategori default dibuat untuk user $userId');
    } else {
      final List<dynamic> arr = jsonDecode(raw);
      list =
          arr
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    // urutkan biar rapi
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    // kembalikan salinan agar aman
    return List<CategoryModel>.from(list);
  }

  // 🔹 Ubah nama kategori (per user)
  Future<void> rename(
    String categoryId,
    String newName, {
    required String userId,
  }) async {
    final list = await listByUser(userId);

    final idx = list.indexWhere((c) => c.id == categoryId);
    if (idx == -1) return;

    // Cegah duplikasi nama
    final dup = list.any(
      (c) =>
          c.id != categoryId &&
          c.name.toLowerCase() == newName.trim().toLowerCase(),
    );
    if (dup) return;

    list[idx] = CategoryModel(id: list[idx].id, name: newName.trim());
    await _saveList(userId, list);
  }

  // 🔹 Hapus kategori (per user)
  Future<void> delete(String categoryId, {required String userId}) async {
    final list = await listByUser(userId);
    list.removeWhere((c) => c.id == categoryId);
    await _saveList(userId, list);
  }
}
