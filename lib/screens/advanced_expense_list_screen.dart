import 'dart:io'; // <-- tambah
import 'package:flutter/material.dart';
import 'package:csv/csv.dart'; // <-- tambah
import 'package:path_provider/path_provider.dart'; // <-- tambah
import 'package:share_plus/share_plus.dart'; // <-- tambah

/// ------------ MODEL ------------
class Expense {
  final String title;
  final String description;
  final String
  category; // contoh: Makanan, Transportasi, Utilitas, Hiburan, Pendidikan
  final double amount;
  final DateTime date;

  Expense({
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });

  // Getter bantu untuk tampilan
  String get formattedAmount => 'Rp ${amount.toStringAsFixed(0)}';
  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  // <-- TAMBAH: baris untuk CSV
  List<String> toCsvRow() => [
    title,
    description,
    category,
    amount.toStringAsFixed(2),
    date.toIso8601String(),
  ];
}

/// ------------ SCREEN ------------
class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({super.key});

  @override
  State<AdvancedExpenseListScreen> createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  // Data contoh (bebas kamu ganti)
  List<Expense> expenses = [
    Expense(
      title: 'Nasi Goreng',
      description: 'Makan malam',
      category: 'Makanan',
      amount: 25000,
      date: DateTime(2025, 10, 1),
    ),
    Expense(
      title: 'Ojek ke Kampus',
      description: 'Transportasi pagi',
      category: 'Transportasi',
      amount: 12000,
      date: DateTime(2025, 10, 1),
    ),
    Expense(
      title: 'Listrik Bulanan',
      description: 'Tagihan PLN',
      category: 'Utilitas',
      amount: 150000,
      date: DateTime(2025, 9, 30),
    ),
    Expense(
      title: 'Netflix',
      description: 'Langganan film',
      category: 'Hiburan',
      amount: 65000,
      date: DateTime(2025, 9, 29),
    ),
    Expense(
      title: 'Buku Flutter',
      description: 'Pemrograman Mobile',
      category: 'Pendidikan',
      amount: 89000,
      date: DateTime(2025, 9, 28),
    ),
    Expense(
      title: 'Es Kopi',
      description: 'Ngopi sore',
      category: 'Makanan',
      amount: 18000,
      date: DateTime(2025, 10, 2),
    ),
  ];

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

  @override
  void initState() {
    super.initState();
    filteredExpenses = List.from(expenses);
  }

  @override
  void dispose() {
    // bagus untuk hindari memory leak
    searchController.dispose();
    super.dispose();
  }

  // <-- TAMBAH: fungsi export ke CSV + share
  Future<void> _exportExpensesToCsv(List<Expense> data) async {
    // header + data
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
        // <-- TAMBAH: tombol Export CSV di AppBar
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
          // Search bar
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

          // Category filter (chips)
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

          // Statistics summary
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

          // Expense list
          Expanded(
            child:
                filteredExpenses.isEmpty
                    ? const Center(
                      child: Text('Tidak ada pengeluaran ditemukan'),
                    )
                    : ListView.builder(
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getCategoryColor(
                                expense.category,
                              ),
                              child: Icon(
                                _getCategoryIcon(expense.category),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(expense.title),
                            subtitle: Text(
                              '${expense.category} • ${expense.formattedDate}',
                            ),
                            trailing: Text(
                              expense.formattedAmount,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[600],
                              ),
                            ),
                            onTap: () => _showExpenseDetails(context, expense),
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

  // ----------------- LOGIC -----------------

  void _filterExpenses() {
    setState(() {
      final kw = searchController.text.toLowerCase();
      filteredExpenses =
          expenses.where((expense) {
            final matchesSearch =
                kw.isEmpty ||
                expense.title.toLowerCase().contains(kw) ||
                expense.description.toLowerCase().contains(kw);

            final matchesCategory =
                selectedCategory == 'Semua' ||
                expense.category == selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList();
    });
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _calculateTotal(List<Expense> list) {
    final total = list.fold<double>(0, (sum, e) => sum + e.amount);
    return 'Rp ${total.toStringAsFixed(0)}';
    // untuk format lokal ID, kamu bisa pakai intl package nanti
  }

  String _calculateAverage(List<Expense> list) {
    if (list.isEmpty) return 'Rp 0';
    final avg = list.fold<double>(0, (s, e) => s + e.amount) / list.length;
    return 'Rp ${avg.toStringAsFixed(0)}';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Makanan':
        return Colors.green;
      case 'Transportasi':
        return Colors.blue;
      case 'Utilitas':
        return Colors.orange;
      case 'Hiburan':
        return Colors.purple;
      case 'Pendidikan':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan':
        return Icons.restaurant;
      case 'Transportasi':
        return Icons.directions_bike;
      case 'Utilitas':
        return Icons.lightbulb;
      case 'Hiburan':
        return Icons.movie;
      case 'Pendidikan':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

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

  // Dialog tambah item sederhana (opsional, biar bisa bermain-main)
  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String cat = 'Makanan';
    final amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
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
              // pilih kategori
              DropdownButtonFormField<String>(
                value: cat,
                items:
                    _categories
                        .where((c) => c != 'Semua')
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (v) => cat = v ?? 'Makanan',
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final desc = descCtrl.text.trim();
                  final amt = double.tryParse(
                    amountCtrl.text.trim() == '' ? '0' : amountCtrl.text.trim(),
                  );

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
                        date: DateTime.now(),
                      ),
                    );
                    _filterExpenses(); // refresh filter juga
                  });

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
  }
}
