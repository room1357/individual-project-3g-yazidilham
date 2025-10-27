class Expense {
  final String id; // uuid/string
  final String title;
  final double amount; // >= 0
  final String categoryId; // relasi ke CategoryModel.id
  final DateTime date;
  final String? description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.description,
  });

  // ---------- Domain JSON (lokal storage / Firestore) ----------
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'categoryId': categoryId,
    'date': date.toIso8601String(),
    'description': description,
  };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
    id: (j['id'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    amount: (j['amount'] as num?)?.toDouble() ?? 0.0,
    categoryId: (j['categoryId'] ?? '').toString(),
    date: _parseDate(j['date']),
    description: (j['description'] as String?),
  );

  // ---------- Adapter untuk API lama (judul/isi_post/created_at/category) ----------
  factory Expense.fromLegacyApi(
    Map<String, dynamic> j, {
    required String Function(String legacyCategory) mapCategoryToId,
  }) {
    final legacyTitle = (j['judul'] ?? j['title'] ?? '').toString();
    final legacyDesc =
        (j['isi_post'] ?? j['body'] ?? j['description'])?.toString();
    final legacyCategory = (j['category'] ?? 'Umum').toString();
    final legacyId = (j['id'] ?? '').toString();
    final amount = (j['amount'] as num?)?.toDouble() ?? 0.0;
    final date = _parseDate(j['created_at']) ?? DateTime.now();

    return Expense(
      id:
          legacyId.isEmpty
              ? DateTime.now().millisecondsSinceEpoch.toString()
              : legacyId,
      title: legacyTitle,
      amount: amount,
      categoryId: mapCategoryToId(legacyCategory), // konversi ke ID
      date: date,
      description: legacyDesc,
    );
  }

  // ---------- Util ----------
  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is DateTime) return raw;
    final s = raw.toString();
    return DateTime.tryParse(s) ?? DateTime.now();
  }

  String get formattedAmount => 'Rp ${amount.toStringAsFixed(0)}';
  String get formattedDate => '${date.day}/${date.month}/${date.year}';

  List<dynamic> toCsvRow({required String categoryName}) => [
    title,
    description ?? '',
    categoryName,
    amount,
    date.toIso8601String(),
  ];

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  @override
  String toString() =>
      'Expense(id: $id, title: $title, amount: $amount, categoryId: $categoryId, date: $date)';

  @override
  bool operator ==(Object o) =>
      o is Expense &&
      o.id == id &&
      o.title == title &&
      o.amount == amount &&
      o.categoryId == categoryId &&
      o.date == date &&
      o.description == description;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      amount.hashCode ^
      categoryId.hashCode ^
      date.hashCode ^
      (description?.hashCode ?? 0);
}
