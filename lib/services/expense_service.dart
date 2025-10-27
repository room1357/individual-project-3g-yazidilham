import 'dart:async';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';

class ExpenseService {
  final Box _box = Hive.box('expenses');

  /// Tambah menggunakan instance Expense langsung
  Future<String> add(Expense e) async {
    await _box.put(e.id, e.toJson());
    return e.id;
  }

  /// Buat Expense baru
  Future<String> create({
    required String ownerId,
    required String title,
    required String description,
    required String categoryId,
    required double amount,
    required DateTime date,
    List<String> sharedWith = const [],
  }) async {
    final id = const Uuid().v4();
    final e = Expense(
      id: id,
      ownerId: ownerId,
      title: title,
      description: description,
      categoryId: categoryId,
      amount: amount,
      date: date,
      sharedWith: sharedWith,
    );
    await _box.put(id, e.toJson());
    return id;
  }

  /// Update sebagian field
  Future<void> update(String id, Map<String, dynamic> data) async {
    final existing = _box.get(id);
    if (existing == null) return;

    final Map<String, dynamic> row = Map<String, dynamic>.from(existing);
    final Map<String, dynamic> patch = Map<String, dynamic>.from(data);

    // Normalisasi date
    if (patch['date'] is DateTime) {
      patch['date'] = (patch['date'] as DateTime).toIso8601String();
    }

    row.addAll(patch);
    await _box.put(id, row);
  }

  /// Get satu expense
  Future<Expense?> getById(String id) async {
    final m = _box.get(id);
    if (m == null) return null;
    return Expense.fromJson(Map<String, dynamic>.from(m));
  }

  /// Ambil semua expense milik user atau yang dibagikan ke user (sekali ambil)
  Future<List<Expense>> listForUser(String userId) async {
    final all = _box.values.cast<dynamic>().toList();
    final result = <Expense>[];

    for (final v in all) {
      final m = Map<String, dynamic>.from(v as Map);
      final exp = Expense.fromJson(m);
      final owned = exp.ownerId == userId;
      final shared = (exp.sharedWith).contains(userId);
      if (owned || shared) result.add(exp);
    }
    return result;
  }

  /// Stream lokal: emit pertama kali + setiap ada perubahan pada box
  Stream<List<Expense>> watchForUser(String userId) {
    final controller = StreamController<List<Expense>>.broadcast();

    Future<void> emit() async {
      controller.add(await listForUser(userId));
    }

    // emit awal
    emit();

    // dengarkan perubahan pada box
    final sub = _box.watch().listen((_) => emit());

    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }
}
