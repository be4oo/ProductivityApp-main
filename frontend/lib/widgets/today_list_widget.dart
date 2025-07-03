import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/persistent_task_provider.dart';
import 'focus_mode_widget.dart';

class TodayListWidget extends StatefulWidget {
  final VoidCallback? onEnlarge;
  final Function(Task)? onFocusTask;

  const TodayListWidget({
    Key? key,
    this.onEnlarge,
    this.onFocusTask,
  }) : super(key: key);

  @override
  State<TodayListWidget> createState() => _TodayListWidgetState();
}

class _TodayListWidgetState extends State<TodayListWidget> {
  Offset _position = const Offset(50, 100);
  bool _isDragging = false;

  List<Task> _getTodayTasks(List<Task> allTasks) {
    final today = DateTime.now();
    return allTasks.where((task) {
      if (task.status == TaskStatus.completed) return false;
      
      // Tasks created today
      if (task.createdAt.day == today.day && 
          task.createdAt.month == today.month && 
          task.createdAt.year == today.year) {
        return true;
      }
      
      // Tasks due today
      if (task.dueDate != null && 
          task.dueDate!.day == today.day && 
          task.dueDate!.month == today.month && 
          task.dueDate!.year == today.year) {
        return true;
      }
      
      // High priority tasks
      if (task.priority == TaskPriority.high) {
        return true;
      }
      
      return false;
    }).take(8).toList(); // Limit to 8 tasks for the floating widget
  }

  void _startFocusMode(Task task) {
    if (widget.onFocusTask != null) {
      widget.onFocusTask!(task);
    } else {
      // Navigate to focus mode
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FocusModeWidget(task: task),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 350,
            constraints: const BoxConstraints(
              minHeight: 200,
              maxHeight: 500,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.today,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Today's Focus",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: widget.onEnlarge ?? () {
                          // Navigate to main app
                          context.go('/home');
                        },
                        icon: Icon(
                          Icons.open_in_full,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(32, 32),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                // Task List
                Expanded(
                  child: Consumer<PersistentTaskProvider>(
                    builder: (context, taskProvider, child) {
                      final todayTasks = _getTodayTasks(taskProvider.tasks);
                      
                      if (todayTasks.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No tasks for today',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: todayTasks.length,
                        itemBuilder: (context, index) {
                          final task = todayTasks[index];
                          return _buildTaskItem(context, task);
                        },
                      );
                    },
                  ),
                ),
                // Resize handle
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Container(
                      width: 30,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Priority indicator
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: _getPriorityColor(task.priority),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.estimatedPomodoros != null && task.estimatedPomodoros! > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task.estimatedPomodoros}🍅',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Focus button
          IconButton(
            onPressed: () {
              _startFocusMode(task);
            },
            icon: const Icon(Icons.play_circle_filled),
            color: Colors.green,
            style: IconButton.styleFrom(
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }
}
