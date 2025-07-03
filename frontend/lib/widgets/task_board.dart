import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/simple_task_provider.dart';
import '../providers/simple_project_provider.dart';
import '../models/models.dart';
import 'task_item.dart';

class TaskBoard extends StatelessWidget {
  const TaskBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer2<SimpleTaskProvider, SimpleProjectProvider>(
      builder: (context, taskProvider, projectProvider, child) {
        final columns = ['Backlog', 'To Do', 'In Progress', 'Done'];
        final selectedProject = projectProvider.selectedProject;
        
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns.map((column) {
              final tasks = selectedProject != null 
                  ? taskProvider.getTasksByColumnAndProject(column, selectedProject.id)
                  : taskProvider.getTasksByColumn(column);
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildColumnHeader(column, tasks.length, colorScheme, theme),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildTaskList(tasks, column, colorScheme, theme, taskProvider),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildColumnHeader(String title, int count, ColorScheme colorScheme, ThemeData theme) {
    Color headerColor;
    switch (title) {
      case 'Backlog':
        headerColor = Colors.grey;
        break;
      case 'This Week':
        headerColor = Colors.blue;
        break;
      case 'Today':
        headerColor = Colors.orange;
        break;
      case 'Done':
        headerColor = Colors.green;
        break;
      default:
        headerColor = colorScheme.primary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: headerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: headerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: headerColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: headerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, String column, ColorScheme colorScheme, ThemeData theme, SimpleTaskProvider taskProvider) {
    return DragTarget<Task>(
      onAcceptWithDetails: (details) {
        final task = details.data;
        if (task.column != column) {
          taskProvider.moveTaskToColumn(task.id, column);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty 
                ? colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: candidateData.isNotEmpty 
                ? Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  )
                : null,
          ),
          child: tasks.isEmpty
              ? Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No tasks',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(4),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Draggable<Task>(
                        data: task,
                        feedback: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 250,
                            child: TaskItem(
                              task: task,
                              isKanban: true,
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: TaskItem(
                            task: task,
                            isKanban: true,
                          ),
                        ),
                        child: TaskItem(
                          task: task,
                          isKanban: true,
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
