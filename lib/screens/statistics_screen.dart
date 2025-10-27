import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../models/user_profile.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _loading = true;
  String? _uid;

  // data
  List<_ExpenseLite> _expenses = [];
  Map<String, double> _totalByCategory = {};
  List<_DayTotal> _dayTotalsThisMonth = [];

  // palet warna untuk pie sections
  final List<Color> _palette = const [
    Color(0xFF4F46E5), // indigo
    Color(0xFF22C55E), // green
    Color(0xFFF59E0B), // amber
    Color(0xFFEF4444), // red
    Color(0xFF06B6D4), // cyan
    Color(0xFF8B5CF6), // violet
    Color(0xFF10B981), // emerald
    Color(0xFFE11D48), // rose
    Color(0xFF3B82F6), // blue
    Color(0xFFA855F7), // purple
  ];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // ambil user
    final user = await AuthService().currentUser();
    _uid = user?.uid ?? 'local-user';

    // load expenses per user
    await _loadExpenses();

    // olah statistik
    _computeTotalsByCategory();
    _computeDayTotalsThisMonth();

    setState(() => _loading = false);
  }

  Future<void> _loadExpenses() async {
    final sp = await SharedPreferences.getInstance();
    final key = 'expenses_$_uid';
    final raw = sp.getString(key);
    if (raw == null || raw.isEmpty) {
      _expenses = [];
      return;
    }
    final List<dynamic> arr = jsonDecode(raw);
    _expenses =
        arr
            .map((e) => _ExpenseLite.fromJson(e as Map<String, dynamic>))
            .toList();
  }

  void _computeTotalsByCategory() {
    final map = <String, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    // sort by value desc (opsional)
    final entries =
        map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    _totalByCategory = {for (final e in entries) e.key: e.value};
  }

  void _computeDayTotalsThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(
      now.year,
      now.month + 1,
      1,
    ).subtract(const Duration(days: 1));
    final dayCount = end.day;

    final map = <int, double>{}; // day -> total
    for (int d = 1; d <= dayCount; d++) {
      map[d] = 0;
    }

    for (final e in _expenses) {
      if (e.date.year == now.year && e.date.month == now.month) {
        map[e.date.day] = (map[e.date.day] ?? 0) + e.amount;
      }
    }

    _dayTotalsThisMonth = [
      for (int d = 1; d <= dayCount; d++) _DayTotal(day: d, total: map[d] ?? 0),
    ];
  }

  String _rp(double v) => 'Rp ${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasData = _expenses.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: () async {
              setState(() => _loading = true);
              await _bootstrap();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            hasData
                ? ListView(
                  children: [
                    // ===== PIE: total per kategori =====
                    const Text(
                      'Total per Kategori',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AspectRatio(
                      aspectRatio: 1.2,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _buildPieSections(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // legend
                    ..._totalByCategory.entries.map((e) {
                      final idx = _categoryIndex(e.key);
                      final color = _palette[idx % _palette.length];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          radius: 8,
                        ),
                        title: Text(e.key),
                        trailing: Text(_rp(e.value)),
                        dense: true,
                      );
                    }),

                    const SizedBox(height: 24),

                    // ===== BAR: total harian bulan berjalan =====
                    Text(
                      'Pengeluaran Harian (${_bulan(DateTime.now().month)} ${DateTime.now().year})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 240,
                      child: BarChart(
                        BarChartData(
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: _labelInterval(
                                  _dayTotalsThisMonth.length,
                                ),
                                getTitlesWidget: (value, meta) {
                                  final d = value.toInt();
                                  if (d <= 0 ||
                                      d > _dayTotalsThisMonth.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      d.toString(),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: _buildBarGroups(),
                        ),
                      ),
                    ),
                  ],
                )
                : const Center(child: Text('Belum ada data')),
      ),
    );
  }

  // ===== Helpers untuk PIE =====
  List<PieChartSectionData> _buildPieSections() {
    if (_totalByCategory.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          title: 'Kosong',
          color: Colors.grey.shade300,
          radius: 80,
          titleStyle: const TextStyle(fontSize: 12),
        ),
      ];
    }
    final totalAll = _totalByCategory.values.fold<double>(0, (s, v) => s + v);
    final sections = <PieChartSectionData>[];
    var i = 0;
    _totalByCategory.forEach((cat, val) {
      final pct = totalAll == 0 ? 0 : (val / totalAll * 100);
      sections.add(
        PieChartSectionData(
          value: val,
          radius: 85,
          color: _palette[i % _palette.length],
          title: '${pct.toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      i++;
    });
    return sections;
  }

  int _categoryIndex(String name) {
    // gunakan urutan map saat ini untuk indeks warna yang konsisten
    final keys = _totalByCategory.keys.toList();
    return keys.indexOf(name);
  }

  // ===== Helpers untuk BAR =====
  List<BarChartGroupData> _buildBarGroups() {
    if (_dayTotalsThisMonth.isEmpty) return [];
    final maxVal = _dayTotalsThisMonth.fold<double>(
      0,
      (m, d) => d.total > m ? d.total : m,
    );
    final barColor = const Color(0xFF3B82F6);
    return _dayTotalsThisMonth.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      // skala tinggi bar otomatis diurus fl_chart; kita cuma set y = total
      final rod = BarChartRodData(
        toY: item.total,
        width: 8,
        borderRadius: BorderRadius.circular(4),
        color: barColor,
      );
      return BarChartGroupData(x: idx + 1, barRods: [rod]);
    }).toList();
  }

  double _labelInterval(int dayCount) {
    if (dayCount <= 10) return 1;
    if (dayCount <= 20) return 2;
    return 3; // untuk 30/31 hari, label tiap 3 hari
  }

  String _bulan(int m) {
    const id = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return id[m];
  }
}

// ===== Model ringan (sesuai struktur yang disimpan AdvancedExpenseListScreen) =====
class _ExpenseLite {
  final String title;
  final String description;
  final String category;
  final double amount;
  final DateTime date;

  _ExpenseLite({
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });

  factory _ExpenseLite.fromJson(Map<String, dynamic> j) => _ExpenseLite(
    title: j['title'] ?? '',
    description: j['description'] ?? '',
    category: j['category'] ?? 'Umum',
    amount: (j['amount'] as num?)?.toDouble() ?? 0,
    date: DateTime.tryParse(j['date'] ?? '') ?? DateTime.now(),
  );
}

class _DayTotal {
  final int day;
  final double total;
  const _DayTotal({required this.day, required this.total});
}
