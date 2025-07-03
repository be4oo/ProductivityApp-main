import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/persistent_task_provider.dart';

class DashboardStatsWidget extends StatelessWidget {
  const DashboardStatsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer<PersistentTaskProvider>(
      builder: (context, taskProvider, child) {
        final stats = taskProvider.dashboardStats;
        
        if (stats == null) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Tasks',
                  stats.totalTasks.toString(),
                  Icons.task_alt,
                  colorScheme.primary,
                  colorScheme,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  stats.completedTasks.toString(),
                  Icons.check_circle,
                  Colors.green,
                  colorScheme,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Today',
                  stats.todayTasks.toString(),
                  Icons.today,
                  Colors.orange,
                  colorScheme,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Overdue',
                  stats.overdueTasks.toString(),
                  Icons.warning,
                  Colors.red,
                  colorScheme,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Completion Rate',
                  '${stats.completionRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  colorScheme.secondary,
                  colorScheme,
                  theme,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
                const Spacer(),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
