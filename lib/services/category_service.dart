// lib/services/category_service.dart
import 'package:uuid/uuid.dart';
import '../models/category.dart';

class CategoryService {
  // singleton agar state bertahan
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  final _uuid = const Uuid();

  // Simpan per user: uid -> list kategori
  final Map<String, List<CategoryModel>> _byUser = {};
  // Index owner: categoryId -> uid (supaya rename/delete cukup pakai id)
  final Map<String, String> _ownerOf = {};

  Future<CategoryModel> create({
    required String userId,
    required String name,
  }) async {
    final id = _uuid.v4();
    final c = CategoryModel(id: id, name: name);
    final list = _byUser.putIfAbsent(userId, () => <CategoryModel>[]);
    list.add(c);
    _ownerOf[id] = userId;
    // urutkan by name asc
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return c;
  }

  Future<List<CategoryModel>> listByUser(String userId) async {
    final list = _byUser[userId] ?? const <CategoryModel>[];
    // kembalikan salinan agar aman
    return List<CategoryModel>.from(list);
  }

  Future<void> rename(String categoryId, String newName) async {
    final uid = _ownerOf[categoryId];
    if (uid == null) return;
    final list = _byUser[uid];
    if (list == null) return;
    final idx = list.indexWhere((c) => c.id == categoryId);
    if (idx < 0) return;
    list[idx] = CategoryModel(id: list[idx].id, name: newName);
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> delete(String categoryId) async {
    final uid = _ownerOf.remove(categoryId);
    if (uid == null) return;
    final list = _byUser[uid];
    list?.removeWhere((c) => c.id == categoryId);
  }
}
