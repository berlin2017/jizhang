import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:jizhang_app/models/transaction.dart' as model;
import 'package:collection/collection.dart';

enum ChartType { pie, line }

class ChartsPage extends StatefulWidget {
  final List<model.Transaction> transactions;

  const ChartsPage({super.key, required this.transactions});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  ChartType _selectedChart = ChartType.pie;
  int touchedIndex = -1;

  final Map<String, Color> _categoryColors = {
    '餐饮': Colors.orange,
    '交通': Colors.blue,
    '购物': Colors.purple,
    '娱乐': Colors.red,
    '其他': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final expenses = widget.transactions.where((tx) => tx.isExpense).toList();

    return Scaffold(
      body: Column(
        children: <Widget>[
          _buildChartTypeSelector(),
          Expanded(
            child: expenses.isEmpty
                ? const Center(
                    child: Text(
                      '没有支出数据可供分析',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : _selectedChart == ChartType.pie
                    ? _buildPieChart(expenses)
                    : _buildLineChart(expenses),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SegmentedButton<ChartType>(
        segments: const <ButtonSegment<ChartType>>[
          ButtonSegment<ChartType>(value: ChartType.pie, label: Text('构成')),
          ButtonSegment<ChartType>(value: ChartType.line, label: Text('趋势')),
        ],
        selected: <ChartType>{_selectedChart},
        onSelectionChanged: (Set<ChartType> newSelection) {
          setState(() {
            _selectedChart = newSelection.first;
          });
        },
      ),
    );
  }

  Widget _buildPieChart(List<model.Transaction> expenses) {
    final groupedExpenses = groupBy<model.Transaction, String>(
      expenses,
      (tx) => tx.category,
    );
    final categoryTotals = groupedExpenses.map(
      (category, txs) => MapEntry(category, txs.fold(0.0, (sum, item) => sum + item.amount)),
    );
    final totalExpense = categoryTotals.values.fold(0.0, (sum, item) => sum + item);

    final List<PieChartSectionData> sections = categoryTotals.entries.mapIndexed((index, entry) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final category = entry.key;
      final total = entry.value;
      final percentage = totalExpense > 0 ? total / totalExpense * 100 : 0;

      return PieChartSectionData(
        color: _categoryColors[category] ?? Colors.grey,
        value: total,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();

    return Column(
      children: <Widget>[
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: sections,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            children: categoryTotals.keys.map((category) {
              return _buildIndicator(
                color: _categoryColors[category] ?? Colors.grey,
                text: category,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(List<model.Transaction> expenses) {
    final recent7Days = List.generate(7, (index) => DateTime.now().subtract(Duration(days: index)));
    final dailyTotals = { for (var day in recent7Days) DateFormat('yyyy-MM-dd').format(day) : 0.0 };

    for (var tx in expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.date);
      if (dailyTotals.containsKey(dateKey)) {
        dailyTotals[dateKey] = dailyTotals[dateKey]! + tx.amount;
      }
    }

    final spots = dailyTotals.entries.map((entry) {
      final dayIndex = recent7Days.indexWhere((day) => DateFormat('yyyy-MM-dd').format(day) == entry.key);
      return FlSpot((6 - dayIndex).toDouble(), entry.value);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = 6 - value.toInt();
                  if (index >= 0 && index < 7) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(DateFormat('E').format(recent7Days[index])),
                    );
                  }
                  return Container();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(4),
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16))
      ],
    );
  }
}
