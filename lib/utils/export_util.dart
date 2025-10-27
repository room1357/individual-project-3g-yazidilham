import 'dart:typed_data';
import 'dart:convert';
import 'dart:io' as io;

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;

import '../models/expense.dart';
import '../models/category.dart';
import '../services/expense_service.dart';
import '../services/category_service.dart';

// EXPORT PDF
class ExportPdf {
  /// Export semua expense → PDF
  static Future<void> exportAll({String filename = 'expenses.pdf'}) async {
    final list = ExpenseService().list(); // ambil semua data lokal
    await exportFromList(list, filename: filename);
  }

  /// Export list tertentu → PDF
  static Future<void> exportFromList(
    List<Expense> list, {
    String filename = 'expenses.pdf',
  }) async {
    final bytes = await _buildPdfBytes(list);
    await Printing.layoutPdf(onLayout: (_) async => bytes, name: filename);
  }

  // =================== Builder PDF ===================
  static Future<Uint8List> _buildPdfBytes(List<Expense> list) async {
    final doc = pw.Document();
    final total = list.fold<double>(0.0, (s, e) => s + e.amount);

    // Ambil nama kategori dari CategoryService
    final categories = await CategoryService().listByUser('local');
    final catById = {for (final c in categories) c.id: c.name};

    // Total per kategori
    final byCategory = <String, double>{};
    for (final e in list) {
      final name = catById[e.categoryId] ?? 'Lainnya';
      byCategory[name] = (byCategory[name] ?? 0) + e.amount;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: pdf.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        footer:
            (ctx) => pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Page ${ctx.pageNumber} / ${ctx.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: pdf.PdfColors.grey700,
                ),
              ),
            ),
        build:
            (ctx) => [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Expense Report',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: pdf.PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        _formatDateTime(DateTime.now()),
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: pdf.PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Total: ${_rp(total)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: pdf.PdfColors.blue700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              if (byCategory.isNotEmpty) ...[
                pw.Text(
                  'Summary by Category',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      byCategory.entries
                          .map((e) => _chip('${e.key}: ${_rp(e.value)}'))
                          .toList(),
                ),
                pw.SizedBox(height: 12),
              ],
              pw.Text(
                'Transactions',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              _expenseTable(list, catById),
            ],
      ),
    );

    return doc.save();
  }

  // ----------------- Helper Widgets -----------------
  static pw.Widget _chip(String text) => pw.Container(
    decoration: pw.BoxDecoration(
      color: pdf.PdfColors.white,
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: pdf.PdfColors.blue300, width: 0.8),
    ),
    padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
  );

  static pw.Widget _expenseTable(
    List<Expense> list,
    Map<String, String> catById,
  ) {
    final headers = ['Title', 'Amount', 'Category', 'Date', 'Description'];
    final data =
        list.map((e) {
          return [
            e.title,
            _rp(e.amount),
            catById[e.categoryId] ?? 'Lainnya',
            _formatDate(e.date),
            (e.description ?? '').replaceAll('\n', ' '),
          ];
        }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerDecoration: const pw.BoxDecoration(
        color: pdf.PdfColor.fromInt(0xFFEFF5FF),
      ),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: pdf.PdfColors.blue900,
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
      border: pw.TableBorder.all(color: pdf.PdfColors.grey300, width: 0.4),
    );
  }

  // ----------------- Formatter -----------------
  static String _rp(double v) => 'Rp ${v.toStringAsFixed(0)}';
  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  static String _formatDateTime(DateTime d) =>
      '${_formatDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// ======================================================
/// =============== EXPORT CSV SECTION ===================
/// ======================================================
class ExportCsv {
  static Future<void> exportAll({String filename = 'expenses.csv'}) async {
    final list = ExpenseService().list();
    await exportFromList(list, filename: filename);
  }

  static Future<void> exportFromList(
    List<Expense> list, {
    String filename = 'expenses.csv',
  }) async {
    final csvString = await _buildCsv(list);
    final csvBytes = utf8.encode(csvString);

    // 📱 ANDROID/iOS/DESKTOP: simpan file dan share
    final dir = await getApplicationDocumentsDirectory();
    final filePath = path.join(dir.path, filename);
    final file = io.File(filePath);
    await file.writeAsBytes(csvBytes);
    print('✅ CSV disimpan sementara di: $filePath');

    await Share.shareXFiles([XFile(filePath)], text: 'Data pengeluaran saya');
  }

  // ----------------- CSV Builder -----------------
  static Future<String> _buildCsv(List<Expense> list) async {
    final categories = await CategoryService().listByUser('local');
    final catById = {for (final c in categories) c.id: c.name};

    final buffer = StringBuffer();
    final headers = ['Title', 'Amount', 'Category', 'Date', 'Description'];
    buffer.writeln(headers.join(','));

    for (final e in list) {
      final row = [
        _escapeCsv(e.title),
        e.amount.toStringAsFixed(0),
        _escapeCsv(catById[e.categoryId] ?? 'Lainnya'),
        _formatDate(e.date),
        _escapeCsv(e.description ?? ''),
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      value = value.replaceAll('"', '""');
      return '"$value"';
    }
    return value;
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
