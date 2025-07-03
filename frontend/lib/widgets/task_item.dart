import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/simple_task_provider.dart';
import 'task_dialog.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final bool isKanban;

  const TaskItem({
    Key? key,
    required this.task,
    this.isKanban = false,
  }) : super(key: key);

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = widget.task.status == TaskStatus.completed;
    final isOverdue = widget.task.dueDate != null &&
        widget.task.dueDate!.isBefore(DateTime.now()) &&
        !isCompleted;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) {
              setState(() {
                _isHovered = true;
              });
              _animationController.forward();
            },
            onExit: (_) {
              setState(() {
                _isHovered = false;
              });
              _animationController.reverse();
            },
            child: GestureDetector(
              onTap: () => _showTaskDialog(),
              onLongPress: () => _showTaskMenu(),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOverdue
                        ? colorScheme.error
                        : colorScheme.outline.withOpacity(0.2),
                    width: isOverdue ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: _isHovered ? 8 : 4,
                      offset: Offset(0, _isHovered ? 4 : 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with priority and status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(widget.task.priority).withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getPriorityIcon(widget.task.priority),
                            size: 16,
                            color: _getPriorityColor(widget.task.priority),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.task.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            _getStatusIcon(widget.task.status),
                            size: 16,
                            color: _getStatusColor(widget.task.status),
                          ),
                        ],
                      ),
                    ),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          if (widget.task.description?.isNotEmpty == true) ...[
                            Text(
                              widget.task.description!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                          ],
                          
                          // Tags
                          if (widget.task.tags?.isNotEmpty == true) ...[
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: widget.task.tags!.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tag,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                          ],
                          
                          // Due date and pomodoros
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (widget.task.dueDate != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOverdue
                                        ? colorScheme.errorContainer
                                        : colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 12,
                                        color: isOverdue
                                            ? colorScheme.onErrorContainer
                                            : colorScheme.onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(widget.task.dueDate!),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isOverdue
                                              ? colorScheme.onErrorContainer
                                              : colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              if (widget.task.estimatedPomodoros != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        size: 12,
                                        color: colorScheme.onTertiaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.task.estimatedPomodoros}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onTertiaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: widget.task,
        projectId: widget.task.projectId,
      ),
    );
  }

  void _showTaskMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Task'),
              onTap: () {
                Navigator.of(context).pop();
                _showTaskDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Focus Mode'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/focus/${widget.task.id}');
              },
            ),
            if (widget.task.status != TaskStatus.completed)
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Mark Complete'),
                onTap: () {
                  Navigator.of(context).pop();
                  _markComplete();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Task'),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _markComplete() {
    final taskProvider = Provider.of<SimpleTaskProvider>(context, listen: false);
    taskProvider.updateTask(
      widget.task.id,
      status: TaskStatus.completed,
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${widget.task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTask();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTask() {
    final taskProvider = Provider.of<SimpleTaskProvider>(context, listen: false);
    taskProvider.deleteTask(widget.task.id);
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
      case TaskPriority.urgent:
        return Icons.priority_high;
    }
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

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.schedule;
      case TaskStatus.done:
        return Icons.check_circle_outline;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.lightGreen;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    
    if (taskDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (taskDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else if (taskDate.isBefore(today)) {
      final difference = today.difference(taskDate).inDays;
      return '${difference}d ago';
    } else {
      final difference = taskDate.difference(today).inDays;
      return 'In ${difference}d';
    }
  }
}
