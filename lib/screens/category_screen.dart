import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/category_service.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _nameCtrl = TextEditingController();
  final _srv = CategoryService(); // <-- pastikan class ini ada (bagian B)

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _add(String uid) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    await _srv.create(userId: uid, name: name);
    _nameCtrl.clear();
    if (mounted) setState(() {});
  }

  // === GANTI: Category -> CategoryModel
  Future<void> _rename(CategoryModel c) async {
    final ctrl = TextEditingController(text: c.name);
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Ubah Nama Kategori'),
            content: TextField(
              controller: ctrl,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
    if (ok == true) {
      await _srv.rename(c.id, ctrl.text.trim());
      if (mounted) setState(() {});
    }
  }

  // === GANTI: Category -> CategoryModel
  Future<void> _delete(CategoryModel c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Hapus Kategori?'),
            content: const Text(
              'Semua pengeluaran di kategori ini bisa terdampak.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
    if (ok == true) {
      await _srv.delete(c.id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().currentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        final uid = user?.uid;

        if (uid == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kategori')),
            body: const Center(child: Text('Silakan login terlebih dahulu.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kategori'),
            backgroundColor: Colors.blue,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama kategori',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _add(uid),
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
              ),
              Expanded(
                // === GANTI: List<Category> -> List<CategoryModel>
                child: FutureBuilder<List<CategoryModel>>(
                  future: _srv.listByUser(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Gagal memuat: ${snapshot.error}'),
                      );
                    }
                    final cats = snapshot.data ?? [];
                    if (cats.isEmpty) {
                      return const Center(child: Text('Belum ada kategori.'));
                    }
                    return ListView.separated(
                      itemCount: cats.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final c = cats[i];
                        return ListTile(
                          title: Text(c.name),
                          subtitle: Text('ID: ${c.id}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _rename(c),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _delete(c),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
