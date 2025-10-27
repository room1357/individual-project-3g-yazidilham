import 'dart:async';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';

class CategoryService {
  final Box _box = Hive.box('categories');

  /// Buat kategori baru
  Future<String> create({required String userId, required String name}) async {
    final id = const Uuid().v4();
    final cat = Category(id: id, userId: userId, name: name);
    await _box.put(id, {'id': cat.id, 'userId': cat.userId, 'name': cat.name});
    return id;
  }

  /// Ganti nama kategori
  Future<void> rename(String id, String newName) async {
    final raw = _box.get(id);
    if (raw == null) return;
    final m = Map<String, dynamic>.from(raw);
    m['name'] = newName;
    await _box.put(id, m);
  }

  /// Hapus kategori
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Ambil daftar kategori milik user (sekali ambil)
  Future<List<Category>> listByUser(String userId) async {
    final all = _box.values.cast<dynamic>();
    return all
        .map((v) => Category.fromJson(Map<String, dynamic>.from(v as Map)))
        .where((c) => c.userId == userId)
        .toList();
  }

  /// (Opsional) Stream lokal bila perlu realtime pada UI
  Stream<List<Category>> watchByUser(String userId) {
    final controller = StreamController<List<Category>>.broadcast();

    Future<void> emit() async {
      controller.add(await listByUser(userId));
    }

    // emit awal + dengarkan perubahan box
    emit();
    final sub = _box.watch().listen((_) => emit());
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }
}
