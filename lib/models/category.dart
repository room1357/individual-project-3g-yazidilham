class Category {
  final String id;
  final String userId; // 🔹 pemilik kategori (uid dari Firebase)
  final String name;

  Category({required this.id, required this.userId, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'name': name};

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: j['id'] as String,
    userId: j['userId'] as String? ?? 'local', // default biar gak error
    name: j['name'] as String,
  );
}
