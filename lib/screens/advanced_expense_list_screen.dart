import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

/// ------------ MODEL ------------
class Expense {
  final String title;
  final String description;
  final String category;
  final double amount;
  final DateTime date;

  Expense({
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'amount': amount,
    'date': date.toIso8601String(),
  };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
    title: j['title'] ?? '',
    description: j['description'] ?? '',
    category: j['category'] ?? 'Umum',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    date: DateTime.tryParse(j['date'] ?? '') ?? DateTime.now(),
  );

  List<String> toCsvRow() => [
    title,
    description,
    category,
    amount.toStringAsFixed(2),
    date.toIso8601String(),
  ];

  String get formattedAmount => 'Rp ${amount.toStringAsFixed(0)}';
  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

/// ------------ SCREEN ------------
class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({super.key});

  @override
  State<AdvancedExpenseListScreen> createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  List<Expense> expenses = [];
  List<Expense> filteredExpenses = [];
  String selectedCategory = 'Semua';
  final TextEditingController searchController = TextEditingController();

  final List<String> _categories = const [
    'Semua',
    'Makanan',
    'Transportasi',
    'Utilitas',
    'Hiburan',
    'Pendidikan',
  ];

  String? _uid; // untuk membedakan user

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    final user = await AuthService().currentUser();
    _uid = user?.uid ?? 'local-user';
    await _loadExpenses(); // load dari SharedPreferences
  }

  Future<void> _loadExpenses() async {
    final sp = await SharedPreferences.getInstance();
    final key = 'expenses_$_uid';
    final jsonData = sp.getString(key);

    if (jsonData != null) {
      final List<dynamic> list = jsonDecode(jsonData);
      expenses =
          list.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      expenses = []; // user baru = data kosong
    }

    filteredExpenses = List.from(expenses);
    setState(() {});
  }

  Future<void> _saveExpenses() async {
    final sp = await SharedPreferences.getInstance();
    final key = 'expenses_$_uid';
    final data = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await sp.setString(key, data);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // EXPORT CSV
  Future<void> _exportExpensesToCsv(List<Expense> data) async {
    final rows = <List<dynamic>>[
      ['title', 'description', 'category', 'amount', 'date'],
      ...data.map((e) => e.toCsvRow()),
    ];

    final csvString = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/expenses_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(csvString, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv', name: 'expenses.csv')],
      text: 'Export data pengeluaran',
      subject: 'Expenses CSV',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran Advanced'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () async {
              final data =
                  filteredExpenses.isEmpty ? expenses : filteredExpenses;
              if (data.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Belum ada data untuk diexport'),
                  ),
                );
                return;
              }
              await _exportExpensesToCsv(data);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Cari pengeluaran...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _filterExpenses(),
            ),
          ),

          // 🏷️ Kategori filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children:
                  _categories
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: selectedCategory == category,
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = category;
                                _filterExpenses();
                              });
                            },
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),

          // Statistik
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', _calculateTotal(filteredExpenses)),
                _buildStatCard('Jumlah', '${filteredExpenses.length} item'),
                _buildStatCard(
                  'Rata-rata',
                  _calculateAverage(filteredExpenses),
                ),
              ],
            ),
          ),

          // Daftar pengeluaran
          Expanded(
            child:
                filteredExpenses.isEmpty
                    ? const Center(
                      child: Text('Tidak ada pengeluaran ditemukan'),
                    )
                    : ListView.builder(
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final e = filteredExpenses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getCategoryColor(e.category),
                              child: Icon(
                                _getCategoryIcon(e.category),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(e.title),
                            subtitle: Text(
                              '${e.category} • ${e.formattedDate}',
                            ),
                            trailing: Text(
                              e.formattedAmount,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            onTap: () => _showExpenseDetails(context, e),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------- LOGIC ----------

  void _filterExpenses() {
    setState(() {
      final q = searchController.text.toLowerCase();
      filteredExpenses =
          expenses.where((e) {
            final matchSearch =
                q.isEmpty ||
                e.title.toLowerCase().contains(q) ||
                e.description.toLowerCase().contains(q);
            final matchCat =
                selectedCategory == 'Semua' || e.category == selectedCategory;
            return matchSearch && matchCat;
          }).toList();
    });
  }

  Widget _buildStatCard(String label, String value) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  );

  String _calculateTotal(List<Expense> list) {
    final total = list.fold<double>(0, (sum, e) => sum + e.amount);
    return 'Rp ${total.toStringAsFixed(0)}';
  }

  String _calculateAverage(List<Expense> list) {
    if (list.isEmpty) return 'Rp 0';
    final avg = list.fold<double>(0, (s, e) => s + e.amount) / list.length;
    return 'Rp ${avg.toStringAsFixed(0)}';
  }

  Color _getCategoryColor(String cat) =>
      {
        'Makanan': Colors.green,
        'Transportasi': Colors.blue,
        'Utilitas': Colors.orange,
        'Hiburan': Colors.purple,
        'Pendidikan': Colors.teal,
      }[cat] ??
      Colors.grey;

  IconData _getCategoryIcon(String cat) =>
      {
        'Makanan': Icons.restaurant,
        'Transportasi': Icons.directions_bike,
        'Utilitas': Icons.lightbulb,
        'Hiburan': Icons.movie,
        'Pendidikan': Icons.school,
      }[cat] ??
      Icons.category;

  void _showExpenseDetails(BuildContext context, Expense e) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(e.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kategori : ${e.category}'),
                Text('Tanggal  : ${e.formattedDate}'),
                Text('Jumlah   : ${e.formattedAmount}'),
                const SizedBox(height: 10),
                Text('Deskripsi:\n${e.description}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String cat = 'Makanan';
    DateTime selectedDate = DateTime.now(); // 🔹 TANGGAL DIPILIH USER

    String _fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        // 🔹 Pakai StatefulBuilder agar UI di bottom sheet bisa setState sendiri
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tambah Pengeluaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Kategori
                  DropdownButtonFormField<String>(
                    value: cat,
                    items:
                        _categories
                            .where((c) => c != 'Semua')
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (v) => cat = v ?? 'Makanan',
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Jumlah
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah (Rp)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 TANGGAL: tampil + tombol pilih date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tanggal'),
                    subtitle: Text(_fmt(selectedDate)),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                      child: const Text('Pilih'),
                    ),
                  ),
                  const SizedBox(height: 14),

                  ElevatedButton.icon(
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      final desc = descCtrl.text.trim();
                      final amt = double.tryParse(amountCtrl.text.trim());
                      if (title.isEmpty || desc.isEmpty || (amt ?? 0) <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lengkapi data dengan benar!'),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        expenses.add(
                          Expense(
                            title: title,
                            description: desc,
                            category: cat,
                            amount: amt!,
                            date: selectedDate, // 🔹 PAKAI TANGGAL PILIHAN
                          ),
                        );
                        _filterExpenses();
                      });
                      _saveExpenses(); // simpan ke SharedPreferences
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
