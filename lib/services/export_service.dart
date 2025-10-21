import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/expense_repository.dart';

class ExportService {
  static Future<void> shareCsv() async {
    final expenses = ExpenseRepository.I.expenses;

    // Ubah ke List<List<String>> untuk CSV
    final rows = [
      ['Judul', 'Deskripsi', 'Kategori', 'Jumlah', 'Tanggal'],
      ...expenses.map(
        (e) => [
          e.title,
          e.description,
          e.categoryId,
          e.amount.toString(),
          e.date.toIso8601String(),
        ],
      ),
    ];

    // Generate CSV
    final csvData = const ListToCsvConverter().convert(rows);

    // Simpan ke file sementara
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/expenses.csv');
    await file.writeAsString(csvData);

    // Share file
    await Share.shareXFiles([XFile(file.path)], text: 'Export Data Expense');
  }
}
