class CategoryModel {
  final String id; // uuid/string
  final String name; // unik per user
  final int? colorHex; // opsional
  final String? icon; // opsional

  CategoryModel({
    required this.id,
    required this.name,
    this.colorHex,
    this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
    id: j['id'] as String,
    name: j['name'] as String,
    colorHex: j['colorHex'] as int?,
    icon: j['icon'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorHex': colorHex,
    'icon': icon,
  };
}
