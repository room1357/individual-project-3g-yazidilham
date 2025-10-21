import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';

Future<void> exportExpensesToCsv(List<Expense> expenses) async {
  final rows = <List<dynamic>>[
    ['title', 'description', 'categoryId', 'amount', 'date'],
    ...expenses.map((e) => e.toCsvRow()),
  ];

  final csv = const ListToCsvConverter().convert(rows);

  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/expenses_${DateTime.now().millisecondsSinceEpoch}.csv',
  );

  await file.writeAsString(csv, flush: true);

  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'text/csv', name: 'expenses.csv')],
    text: 'Export data pengeluaran',
    subject: 'Expenses CSV',
  );
}
