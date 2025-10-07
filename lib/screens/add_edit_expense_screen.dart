import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/expense_repository.dart';
import '../models/expense.dart';
import '../models/category.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? initial;
  const AddEditExpenseScreen({super.key, this.initial});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _desc;
  late TextEditingController _amount;
  late DateTime _date;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    _title = TextEditingController(text: e?.title ?? '');
    _desc = TextEditingController(text: e?.description ?? '');
    _amount = TextEditingController(text: e?.amount.toString() ?? '');
    _date = e?.date ?? DateTime.now();
    _categoryId =
        e?.categoryId ??
        (ExpenseRepository.I.categories.isNotEmpty
            ? ExpenseRepository.I.categories.first.id
            : null);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih kategori')));
      return;
    }
    final amt = double.tryParse(_amount.text) ?? 0;
    if (amt <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Jumlah tidak valid')));
      return;
    }

    if (widget.initial == null) {
      final e = Expense(
        id: const Uuid().v4(),
        title: _title.text.trim(),
        description: _desc.text.trim(),
        categoryId: _categoryId!,
        amount: amt,
        date: _date,
      );
      await ExpenseRepository.I.addExpense(e);
    } else {
      final e = Expense(
        id: widget.initial!.id,
        title: _title.text.trim(),
        description: _desc.text.trim(),
        categoryId: _categoryId!,
        amount: amt,
        date: _date,
      );
      await ExpenseRepository.I.updateExpense(e);
    }
    if (context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cats = ExpenseRepository.I.categories;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initial == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran',
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categoryId,
                items:
                    cats
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        (double.tryParse(v ?? '') ?? 0) <= 0
                            ? 'Harus > 0'
                            : null,
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
