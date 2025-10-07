import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/expense_repository.dart';

class ExportService {
  static Future<File> exportCsv() async {
    final list = ExpenseRepository.I.expenses;
    final rows = <List<dynamic>>[
      ['ID', 'Judul', 'Deskripsi', 'Kategori', 'Jumlah', 'Tanggal'],
      ...list.map(
        (e) => [
          e.id,
          e.title,
          e.description,
          ExpenseRepository.I.categoryName(e.categoryId),
          e.amount,
          e.date.toIso8601String(),
        ],
      ),
    ];
    final csv = const ListToCsvConverter().convert(rows);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/expenses.csv');
    return file.writeAsString(csv);
  }

  static Future<void> shareCsv() async {
    final file = await exportCsv();
    await Share.shareXFiles([XFile(file.path)], text: 'Data Pengeluaran');
  }
}
