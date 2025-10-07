import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/expense_repository.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totals = ExpenseRepository.I.totalByCategory();
    final entries = totals.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            entries.isEmpty
                ? const Center(child: Text('Belum ada data'))
                : Column(
                  children: [
                    const Text(
                      'Total per Kategori',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            for (int i = 0; i < entries.length; i++)
                              PieChartSectionData(
                                value: entries[i].value,
                                title: entries[i].key,
                                radius: 80,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...entries.map(
                      (e) => ListTile(
                        leading: const Icon(Icons.label),
                        title: Text(e.key),
                        trailing: Text('Rp ${e.value.toStringAsFixed(0)}'),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
