// lib/presentation/personnel/chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:depron_app/data/services/data_service.dart';
import 'package:depron_app/data/models/grid_analysis_model.dart';

class ChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    // StreamBuilder لقراءة البيانات الفورية من Realtime DB
    return StreamBuilder<List<GridAnalysisModel>>(
      stream: dataService.gridAnalysisStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text('جاري تحميل بيانات التحليل...'));
        }
        if (snapshot.hasError) {
          return Center(child: Text('خطأ: ${snapshot.error}'));
        }

        final grids = snapshot.data ?? [];
        if (grids.isEmpty) {
          return const Center(child: Text('لا توجد بيانات تحليل Grids لعرضها.'));
        }

        // 💡 تجميع البيانات المطلوبة للرسم البياني
        // مثال: حساب إجمالي عدد الأفراد في جميع المناطق
        final totalHumanCount = grids.fold<int>(
            0, (sum, item) => sum + item.humanCount);

        // هذا مثال بسيط جداً (Bar Chart) يعرض العدد لكل منطقة
        List<BarChartGroupData> barGroups = grids
            .asMap()
            .entries
            .map((entry) {
              int index = entry.key;
              GridAnalysisModel grid = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: grid.humanCount.toDouble(),
                    color: grid.status == 'Humanitarian Aid Area'
                        ? Colors.red.shade700
                        : Colors.blue,
                    width: 15,
                  ),
                ],
                showingTooltipIndicators: [0],
              );
            })
            .toList();

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إجمالي عدد الأفراد المكتشفين: $totalHumanCount',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (totalHumanCount * 1.5) > 100 ? (totalHumanCount * 1.2) : 100, // مقياس مناسب
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            // عرض Grid ID على المحور X
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(grids[value.toInt()].gridId,
                                  style: const TextStyle(fontSize: 10)),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}