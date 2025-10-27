import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // pakai AuthService lokal
import '../services/category_service.dart';
import '../services/expense_service.dart';
import '../models/category.dart';
import '../models/user_profile.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final String? expenseId; // null = tambah, isi = edit
  const AddEditExpenseScreen({super.key, this.expenseId});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _amount = TextEditingController();
  final _sharedWithCtrl = TextEditingController(); // userId dipisahkan koma

  DateTime _date = DateTime.now();
  String? _selectedCategory;

  final _srvCat = CategoryService();
  final _srvExp = ExpenseService();

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _amount.dispose();
    _sharedWithCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(String uid) async {
    if (_title.text.trim().isEmpty ||
        _amount.text.trim().isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi semua field")));
      return;
    }

    final amt = double.tryParse(_amount.text.trim()) ?? 0;
    if (amt <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Jumlah tidak valid")));
      return;
    }

    if (widget.expenseId == null) {
      // ➜ pakai add(...)
      await _srvExp.add(
        title: _title.text.trim(),
        amount: amt,
        categoryId: _selectedCategory!, // id kategori
        date: _date,
        description: _desc.text.trim(),
        // NOTE: kalau service-mu belum mendukung sharedWith/ownerId, abaikan dulu
      );
    } else {
      // ➜ pakai update(...) dgn named params
      await _srvExp.update(
        id: widget.expenseId!,
        title: _title.text.trim(),
        amount: amt,
        categoryId: _selectedCategory!,
        date: _date,
        description: _desc.text.trim(),
      );
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Ambil user aktif secara async
    return FutureBuilder<UserProfile?>(
      future: AuthService().currentUser(),
      builder: (context, snapUser) {
        if (snapUser.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final uid = snapUser.data?.uid;
        if (uid == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tambah Pengeluaran')),
            body: const Center(child: Text('Silakan login terlebih dahulu.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.expenseId == null
                  ? 'Tambah Pengeluaran'
                  : 'Edit Pengeluaran',
            ),
            backgroundColor: Colors.blue,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _desc,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // 🔹 Dropdown kategori via FutureBuilder (Hive)
                FutureBuilder<List<CategoryModel>>(
                  future: _srvCat.listByUser(uid),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Gagal memuat kategori: ${snapshot.error}');
                    }
                    final cats = snapshot.data ?? [];
                    if (cats.isEmpty) {
                      return const Text("Belum ada kategori. Buat dulu.");
                    }
                    _selectedCategory ??= cats.first.id;

                    return DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items:
                          cats
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Jumlah (Rp)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tanggal'),
                  subtitle: Text('${_date.day}-${_date.month}-${_date.year}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: const Text('Pilih'),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _sharedWithCtrl,
                  decoration: const InputDecoration(
                    labelText:
                        'Bagikan ke (userId pisahkan dengan koma, opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _save(uid),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("SIMPAN"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
