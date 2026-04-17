import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/providers/db_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // We are listening to all necessary providers
    final paymentsAsync = ref.watch(paymentsProvider);
    final expensesAsync = ref.watch(expensesProvider);
    final attendanceAsync = ref.watch(attendanceProvider);
    final quizzesAsync = ref.watch(allQuizResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والتحليلات', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: (paymentsAsync.isLoading || expensesAsync.isLoading || attendanceAsync.isLoading || quizzesAsync.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFinancialChart(context, ref, colorScheme),
                const SizedBox(height: 24),
                _buildAttendanceChart(context, ref, colorScheme),
                const SizedBox(height: 24),
                _buildQuizzesChart(context, ref, colorScheme),
                const SizedBox(height: 48), // Bottom padding
              ],
            ),
    );
  }

  Widget _buildFinancialChart(BuildContext context, WidgetRef ref, ColorScheme colors) {
    final payments = ref.watch(paymentsProvider).value ?? [];
    final expenses = ref.watch(expensesProvider).value ?? [];

    // Group by month
    // Simplified logic: Just calculate current month totals
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    
    double totalIncome = 0;
    for (var p in payments) {
      if (p.paymentDate.startsWith(currentMonth)) totalIncome += p.amount;
    }

    double totalExpenses = 0;
    for (var e in expenses) {
      if (e.expenseDate.startsWith(currentMonth)) totalExpenses += e.amount;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الملخص المالي (الشهر الحالي)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: (totalIncome > totalExpenses ? totalIncome : totalExpenses) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              value == 0 ? 'الدخل' : 'المنصرف',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: totalIncome,
                          color: Colors.green,
                          width: 40,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: totalIncome == 0 ? 100 : totalIncome * 1.2,
                            color: Colors.green.withAlpha(20),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: totalExpenses,
                          color: Colors.redAccent,
                          width: 40,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: totalExpenses == 0 ? 100 : (totalIncome > totalExpenses ? totalIncome : totalExpenses) * 1.2,
                            color: Colors.redAccent.withAlpha(20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _LegendItem(color: Colors.green, label: 'دخل: ${totalIncome.toStringAsFixed(0)}'),
                _LegendItem(color: Colors.redAccent, label: 'منصرف: ${totalExpenses.toStringAsFixed(0)}'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart(BuildContext context, WidgetRef ref, ColorScheme colors) {
    final attendance = ref.watch(attendanceProvider).value ?? [];
    int present = 0;
    int absent = 0;
    int excused = 0;

    for (var a in attendance) {
      if (a.status == 'present') {
        present++;
      } else if (a.status == 'absent') {
        absent++;
      } else if (a.status == 'excused') {
        excused++;
      }
    }

    final total = present + absent + excused;
    if (total == 0) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('توزيع الحضور العام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: present.toDouble(),
                      title: '${((present / total) * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: absent.toDouble(),
                      title: '${((absent / total) * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: excused.toDouble(),
                      title: '${((excused / total) * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _LegendItem(color: Colors.blue, label: 'حاضر ($present)'),
                _LegendItem(color: Colors.red, label: 'غائب ($absent)'),
                _LegendItem(color: Colors.orange, label: 'بعذر ($excused)'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuizzesChart(BuildContext context, WidgetRef ref, ColorScheme colors) {
    final quizzes = ref.watch(allQuizResultsProvider).value ?? [];
    
    // Distribute results into brackets
    int excellent = 0; // >= 85%
    int good = 0;      // 65% - 84%
    int pass = 0;      // 50% - 64%
    int fail = 0;      // < 50%

    for (var r in quizzes) {
      if (r.percentage >= 85) {
        excellent++;
      } else if (r.percentage >= 65) {
        good++;
      } else if (r.percentage >= 50) {
        pass++;
      } else {
        fail++;
      }
    }

    final total = quizzes.length;
    if (total == 0) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('توزيع الدرجات (كافة الاختبارات)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (excellent > good ? excellent : good).toDouble() + 5,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          String text = '';
                          switch (value.toInt()) {
                            case 0: text = 'ممتاز'; break;
                            case 1: text = 'جيد'; break;
                            case 2: text = 'مقبول'; break;
                            case 3: text = 'ضعيف'; break;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _makeBarGroup(0, excellent.toDouble(), Colors.green),
                    _makeBarGroup(1, good.toDouble(), Colors.blue),
                    _makeBarGroup(2, pass.toDouble(), Colors.orange),
                    _makeBarGroup(3, fail.toDouble(), Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
      showingTooltipIndicators: [0], // To show value on top if needed
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
