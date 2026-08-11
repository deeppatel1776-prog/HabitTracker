import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/stats_provider.dart';

enum ChartPeriod { weekly, monthly, yearly }

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  ChartPeriod _period = ChartPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Stats'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented Period Control
            Container(
              height: 46,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.inputBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildPeriodTab('Weekly', ChartPeriod.weekly),
                  _buildPeriodTab('Monthly', ChartPeriod.monthly),
                  _buildPeriodTab('Yearly', ChartPeriod.yearly),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bar Chart Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _period == ChartPeriod.weekly
                            ? 'Weekly Completion'
                            : _period == ChartPeriod.monthly
                                ? '30-Day Completion Trend'
                                : 'Yearly Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Habits Done',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(stats),
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (val, meta) => Text(
                                val.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) => _getBottomTitle(val.toInt()),
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (val) => FlLine(
                            color: AppColors.textMuted.withOpacity(0.15),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _getBarGroups(stats),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Performance Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 14),

            // Summary Grid Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.35,
              children: [
                _buildStatCard(
                  'Daily Rate',
                  "${stats.dailyCompletionPercentage.toInt()}%",
                  Icons.pie_chart_rounded,
                  AppColors.primary,
                  'Today\'s progress',
                ),
                _buildStatCard(
                  'Consistency',
                  "${stats.consistencyPercentage.toInt()}%",
                  Icons.insights_rounded,
                  AppColors.accent,
                  '30-day average',
                ),
                _buildStatCard(
                  'Current Streak',
                  "${stats.currentMaxStreak} Days",
                  Icons.local_fire_department_rounded,
                  const Color(0xFFFF6B6B),
                  'Active momentum',
                ),
                _buildStatCard(
                  'Longest Streak',
                  "${stats.longestOverallStreak} Days",
                  Icons.workspace_premium_rounded,
                  const Color(0xFFFFBE0B),
                  'Personal record',
                ),
                _buildStatCard(
                  'Total Done',
                  "${stats.totalCompletedSessions}",
                  Icons.check_circle_rounded,
                  AppColors.success,
                  'Habits completed',
                ),
                _buildStatCard(
                  'Active Habits',
                  "${stats.totalActiveHabits}",
                  Icons.track_changes_rounded,
                  const Color(0xFF8338EC),
                  'In progress',
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String title, ChartPeriod period) {
    final isSelected = _period == period;
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _period = period;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primary : secondaryTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxY(HabitStats stats) {
    if (_period == ChartPeriod.weekly) {
      final maxVal = stats.weeklyData.fold<double>(0.0, (m, v) => v > m ? v : m);
      return maxVal < 5 ? 5 : maxVal + 2;
    } else if (_period == ChartPeriod.monthly) {
      final maxVal = stats.monthlyData.fold<double>(0.0, (m, v) => v > m ? v : m);
      return maxVal < 5 ? 5 : maxVal + 2;
    } else {
      final maxVal = stats.yearlyData.fold<double>(0.0, (m, v) => v > m ? v : m);
      return maxVal < 10 ? 10 : maxVal + 5;
    }
  }

  Widget _getBottomTitle(int index) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    if (_period == ChartPeriod.weekly) {
      if (index >= 0 && index < days.length) {
        return Text(days[index], style: TextStyle(fontSize: 11, color: secondaryTextColor));
      }
    } else if (_period == ChartPeriod.yearly) {
      if (index >= 0 && index < months.length) {
        return Text(months[index], style: TextStyle(fontSize: 11, color: secondaryTextColor));
      }
    } else {
      if (index % 5 == 0 && index < 30) {
        return Text("${index + 1}", style: TextStyle(fontSize: 10, color: secondaryTextColor));
      }
    }
    return const SizedBox();
  }

  List<BarChartGroupData> _getBarGroups(HabitStats stats) {
    List<double> data = [];
    if (_period == ChartPeriod.weekly) {
      data = stats.weeklyData;
    } else if (_period == ChartPeriod.monthly) {
      data = stats.monthlyData;
    } else {
      data = stats.yearlyData;
    }

    return List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data[i],
            gradient: AppColors.primaryGradient,
            width: _period == ChartPeriod.monthly ? 6 : 14,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textMuted.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
