import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';

class ExpenseService {
  final _col = FirebaseFirestore.instance.collection('expenses');

  Future<String> add(Expense e) async {
    await _col.doc(e.id).set(e.toJson());
    return e.id;
  }

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
    await _col.doc(id).set(e.toJson());
    return id;
  }

  /// ✅ Tambahkan ini untuk edit expense
  Future<void> update(String id, Map<String, dynamic> data) async {
    final d = Map<String, dynamic>.from(data);

    // pastikan field date kalau masih DateTime diubah ke String ISO
    if (d['date'] is DateTime) {
      d['date'] = (d['date'] as DateTime).toIso8601String();
    }

    await _col.doc(id).update(d);
  }

  /// ✅ Ambil satu expense by id
  Future<Expense?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return Expense.fromJson(doc.data()!);
  }

  // tampilkan semua pengeluaran yang melibatkan user (miliknya atau dibagikan kepadanya)
  Stream<List<Expense>> streamForUser(String userId) {
    final own = _col.where('ownerId', isEqualTo: userId).snapshots();
    final shared = _col.where('sharedWith', arrayContains: userId).snapshots();

    Stream<List<Expense>> map(QS) =>
        QS.map((s) => s.docs.map((d) => Expense.fromJson(d.data())).toList());

    return own.asyncMap((ownSnap) async {
      final sharedSnap = await shared.first;
      final a = ownSnap.docs.map((d) => Expense.fromJson(d.data())).toList();
      final b = sharedSnap.docs.map((d) => Expense.fromJson(d.data())).toList();

      final mapById = {for (var e in a) e.id: e, for (var e in b) e.id: e};
      return mapById.values.toList();
    });
  }
}
