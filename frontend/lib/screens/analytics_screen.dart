import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/simple_task_provider.dart';
import '../models/models.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Week';
  final List<String> _periods = ['Week', 'Month', 'Quarter', 'Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) {
              return _periods.map((period) {
                return PopupMenuItem(
                  value: period,
                  child: Text(period),
                );
              }).toList();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<SimpleTaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                _buildOverviewCards(tasks),
                
                const SizedBox(height: 24),
                
                // Productivity Chart
                _buildProductivityChart(tasks),
                
                const SizedBox(height: 24),
                
                // Priority Distribution
                _buildPriorityDistribution(tasks),
                
                const SizedBox(height: 24),
                
                // Completion Rate
                _buildCompletionRate(tasks),
                
                const SizedBox(height: 24),
                
                // Recent Activity
                _buildRecentActivity(tasks),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(List<Task> tasks) {
    final completedTasks = tasks.where((task) => task.status == TaskStatus.completed).length;
    final totalTasks = tasks.length;
    final inProgressTasks = tasks.where((task) => task.status == TaskStatus.inProgress).length;
    final overdueTasks = tasks.where((task) => 
        task.dueDate != null && 
        task.dueDate!.isBefore(DateTime.now()) && 
        task.status != TaskStatus.completed
    ).length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildOverviewCard(
          title: 'Completed',
          value: completedTasks.toString(),
          subtitle: 'Tasks',
          color: Colors.green,
          icon: Icons.check_circle,
        ),
        _buildOverviewCard(
          title: 'In Progress',
          value: inProgressTasks.toString(),
          subtitle: 'Tasks',
          color: Colors.blue,
          icon: Icons.schedule,
        ),
        _buildOverviewCard(
          title: 'Completion Rate',
          value: totalTasks > 0 ? '${(completedTasks / totalTasks * 100).toInt()}%' : '0%',
          subtitle: 'Success Rate',
          color: Colors.purple,
          icon: Icons.trending_up,
        ),
        _buildOverviewCard(
          title: 'Overdue',
          value: overdueTasks.toString(),
          subtitle: 'Tasks',
          color: Colors.red,
          icon: Icons.warning,
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityChart(List<Task> tasks) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productivity Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(days[value.toInt() % days.length]);
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateProductivityData(tasks),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateProductivityData(List<Task> tasks) {
    // Generate sample data for the chart
    // In a real app, this would be calculated from actual task completion data
    return [
      const FlSpot(0, 3),
      const FlSpot(1, 5),
      const FlSpot(2, 4),
      const FlSpot(3, 7),
      const FlSpot(4, 6),
      const FlSpot(5, 8),
      const FlSpot(6, 5),
    ];
  }

  Widget _buildPriorityDistribution(List<Task> tasks) {
    final priorityCount = <TaskPriority, int>{};
    for (final task in tasks) {
      priorityCount[task.priority] = (priorityCount[task.priority] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Priority Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: _buildPieChartSections(priorityCount),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildPriorityLegend(priorityCount),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<TaskPriority, int> priorityCount) {
    final colors = {
      TaskPriority.low: Colors.green,
      TaskPriority.medium: Colors.orange,
      TaskPriority.high: Colors.red,
      TaskPriority.urgent: Colors.purple,
    };

    return TaskPriority.values.map((priority) {
      final count = priorityCount[priority] ?? 0;
      final total = priorityCount.values.fold(0, (sum, count) => sum + count);
      final percentage = total > 0 ? (count / total * 100) : 0;

      return PieChartSectionData(
        color: colors[priority],
        value: count.toDouble(),
        title: '${percentage.toInt()}%',
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).where((section) => section.value > 0).toList();
  }

  Widget _buildPriorityLegend(Map<TaskPriority, int> priorityCount) {
    final colors = {
      TaskPriority.low: Colors.green,
      TaskPriority.medium: Colors.orange,
      TaskPriority.high: Colors.red,
      TaskPriority.urgent: Colors.purple,
    };

    final labels = {
      TaskPriority.low: 'Low',
      TaskPriority.medium: 'Medium',
      TaskPriority.high: 'High',
      TaskPriority.urgent: 'Urgent',
    };

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: TaskPriority.values.map((priority) {
        final count = priorityCount[priority] ?? 0;
        if (count == 0) return const SizedBox.shrink();

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[priority],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text('${labels[priority]} ($count)'),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCompletionRate(List<Task> tasks) {
    final completedTasks = tasks.where((task) => task.status == TaskStatus.completed).length;
    final totalTasks = tasks.length;
    final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion Rate',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(completionRate * 100).toInt()}%',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: completionRate,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$completedTasks of $totalTasks tasks completed',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(List<Task> tasks) {
    final recentTasks = tasks
        .where((task) => task.updatedAt != null)
        .toList()
      ..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (recentTasks.isEmpty)
              const Text('No recent activity')
            else
              ...recentTasks.take(5).map((task) => _buildActivityItem(task)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Task task) {
    IconData icon;
    Color color;
    String action;

    switch (task.status) {
      case TaskStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        action = 'Completed';
        break;
      case TaskStatus.inProgress:
        icon = Icons.schedule;
        color = Colors.blue;
        action = 'Started';
        break;
      case TaskStatus.cancelled:
        icon = Icons.cancel;
        color = Colors.red;
        action = 'Cancelled';
        break;
      default:
        icon = Icons.task;
        color = Colors.grey;
        action = 'Created';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  action,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (task.updatedAt != null)
            Text(
              _formatRelativeTime(task.updatedAt!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
