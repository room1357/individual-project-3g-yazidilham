// lib/services/expense_service.dart
import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';

/// Service sederhana yang menyimpan data di memori (bisa kamu ganti ke Hive/Firestore nanti).
class ExpenseService {
  // ====== SINGLETON OPSIONAL (biar gampang diakses) ======
  static final ExpenseService _singleton = ExpenseService._internal();
  factory ExpenseService() => _singleton;

  // Named constructor jika mau inisialisasi khusus (mis. dari storage lain)
  ExpenseService.withSeed(List<Expense> seed) {
    _items = [...seed];
    _emit();
  }

  ExpenseService._internal();

  // ====== STATE & STREAM ======
  final _uuid = const Uuid();
  final _ctrl = StreamController<List<Expense>>.broadcast();
  List<Expense> _items = []; // simpan semua expense di memori

  /// Stream semua expense (tanpa filter user)
  Stream<List<Expense>> watchAll() => _ctrl.stream;

  /// Stream dengan filter userId (kalau kamu pakai multi-user)
  Stream<List<Expense>> watchForUser(String uid) async* {
    // kalau belum ada kolom userId di model, untuk sementara balikin semua
    // Nanti ganti filter: where(e.userId == uid)
    yield* _ctrl.stream;
  }

  /// Alias agar kompatibel dengan pemanggilan lama: watchforUser(...)
  Stream<List<Expense>> watchforUser(String uid) => watchForUser(uid);

  // ====== EMIT HELPER ======
  void _emit() {
    // sort default: terbaru di atas
    final sorted = [..._items]..sort((a, b) => b.date.compareTo(a.date));
    _ctrl.add(sorted);
  }

  // ====== QUERY SINKRON (untuk pemanggilan non-stream) ======
  List<Expense> list({String? categoryId}) {
    final data =
        categoryId == null
            ? _items
            : _items.where((e) => e.categoryId == categoryId).toList();
    data.sort((a, b) => b.date.compareTo(a.date));
    return data;
  }

  Expense? getById(String id) {
    return _items.cast<Expense?>().firstWhere(
      (e) => e?.id == id,
      orElse: () => null,
    );
  }

  // ====== MUTASI ======
  Future<Expense> add({
    required String title,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? description,
    String? id,
  }) async {
    final e = Expense(
      id: id ?? _uuid.v4(),
      title: title,
      amount: amount,
      categoryId: categoryId,
      date: date,
      description: description,
    );
    _items.add(e);
    _emit();
    return e;
  }

  Future<void> upsert(Expense e) async {
    final idx = _items.indexWhere((x) => x.id == e.id);
    if (idx >= 0) {
      _items[idx] = e;
    } else {
      _items.add(e);
    }
    _emit();
  }

  Future<void> update({
    required String id,
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? description,
  }) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final cur = _items[idx];
    _items[idx] = cur.copyWith(
      title: title,
      amount: amount,
      categoryId: categoryId,
      date: date,
      description: description,
    );
    _emit();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
    _emit();
  }

  // ====== DISPOSE (opsional) ======
  void dispose() {
    _ctrl.close();
  }
}
