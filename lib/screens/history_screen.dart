import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout_card.dart';

class HistoryScreen extends StatelessWidget {
  final String userId;
  const HistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (_, provider, __) {
        final workouts = provider.workouts;
        final weekData = provider.weeklyCalories;

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Workout History',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const Text('Your weekly activity overview',
                          style:
                              TextStyle(fontSize: 13, color: Colors.black45)),
                      const SizedBox(height: 20),
                      _buildChart(weekData),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: workouts.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(children: [
                              Icon(Icons.history_outlined,
                                  size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              const Text('No workouts yet',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black45)),
                            ]),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => WorkoutCard(
                            workout: workouts[i],
                            onDelete: () =>
                                provider.deleteWorkout(workouts[i].id),
                          ),
                          childCount: workouts.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(Map<String, int> weekData) {
    final entries = weekData.entries.toList();
    final maxY = weekData.values.fold(0, (a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department,
                  color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 6),
              Text('Calories This Week',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY == 0 ? 500 : maxY * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF302B63),
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '${rod.toY.round()} kcal',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) => Text(
                        entries[val.toInt()].key,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black45),
                      ),
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: entries.asMap().entries.map((e) {
                  final hasData = e.value.value > 0;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value.toDouble(),
                        gradient: hasData
                            ? const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              )
                            : null,
                        color: hasData ? null : Colors.grey.shade200,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
