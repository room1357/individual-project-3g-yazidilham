import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';

class CategoryService {
  final _col = FirebaseFirestore.instance.collection('categories');

  Future<String> create({required String userId, required String name}) async {
    final id = const Uuid().v4();
    final cat = Category(id: id, userId: userId, name: name);
    await _col.doc(id).set(cat.toJson());
    return id;
  }

  Future<void> rename(String id, String newName) async {
    await _col.doc(id).update({'name': newName});
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<Category>> streamByUser(String userId) => _col
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((s) => s.docs.map((d) => Category.fromJson(d.data())).toList());
}
