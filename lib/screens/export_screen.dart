import 'package:flutter/material.dart';
import '../utils/export_util.dart'; // pakai ExportCsv & ExportPdf dari utils kamu

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  Future<void> _doExportCsv(BuildContext context) async {
    try {
      // Export semua data (utilitas kamu sudah handle share/save)
      await ExportCsv.exportAll(filename: 'expenses.csv');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export CSV berhasil')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal export CSV: $e')));
      }
    }
  }

  Future<void> _doExportPdf(BuildContext context) async {
    try {
      await ExportPdf.exportAll(filename: 'expenses.pdf');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export PDF dibuka (print/share)')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal export PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pilih format untuk mengekspor data pengeluaran Anda.',
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ExportTile(
              icon: Icons.table_view,
              color: Colors.teal,
              title: 'Export ke CSV',
              subtitle: 'Cocok untuk Excel / Spreadsheet',
              onTap: () => _doExportCsv(context),
            ),
            const SizedBox(height: 12),
            _ExportTile(
              icon: Icons.picture_as_pdf,
              color: Colors.deepOrange,
              title: 'Export ke PDF',
              subtitle: 'Siap dicetak / dibagikan sebagai dokumen',
              onTap: () => _doExportPdf(context),
            ),
            const Spacer(),
            Text(
              'Tips: di Android/iOS file akan dibagikan lewat Share dialog.\n'
              'Di Web, CSV akan otomatis diunduh, PDF dibuka via print dialog.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
