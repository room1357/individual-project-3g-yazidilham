class Expense {
  final String id;
  final String title;
  final String description;
  final String categoryId; // bisa diganti enum
  final double amount;
  final DateTime date;

  // 🔹 tambahan untuk multi-user
  final String ownerId; // userId dari Firebase
  final List<String> sharedWith; // userId lain yang berbagi expense ini

  Expense({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.ownerId = 'local', // default biar kode lama gak error
    this.sharedWith = const [], // default biar kode lama gak error
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'categoryId': categoryId,
    'amount': amount,
    'date': date.toIso8601String(),
    'ownerId': ownerId,
    'sharedWith': sharedWith,
  };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
    id: j['id'] as String,
    title: j['title'] as String,
    description: j['description'] as String,
    categoryId: j['categoryId'] as String,
    amount: (j['amount'] as num).toDouble(),
    date: DateTime.parse(j['date'] as String),
    ownerId: j['ownerId'] ?? 'local',
    sharedWith: (j['sharedWith'] as List?)?.cast<String>() ?? const [],
  );

  List<String> toCsvRow() => [
    title,
    description,
    categoryId,
    amount.toString(),
    date.toIso8601String(),
  ];
}
