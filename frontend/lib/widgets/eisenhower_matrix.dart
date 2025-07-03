import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/persistent_task_provider.dart';
import '../providers/persistent_project_provider.dart';
import 'task_item.dart';

class EisenhowerMatrix extends StatefulWidget {
  const EisenhowerMatrix({Key? key}) : super(key: key);

  @override
  State<EisenhowerMatrix> createState() => _EisenhowerMatrixState();
}

class _EisenhowerMatrixState extends State<EisenhowerMatrix> {
  int? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer2<PersistentTaskProvider, PersistentProjectProvider>(
      builder: (context, taskProvider, projectProvider, child) {
        // Filter tasks by selected project
        var filteredTasks = taskProvider.tasks;
        if (_selectedProjectId != null) {
          filteredTasks = filteredTasks.where((task) => task.projectId == _selectedProjectId).toList();
        }

        // Categorize tasks into quadrants
        final urgentImportant = filteredTasks.where((task) => task.isUrgent && task.isImportant).toList();
        final notUrgentImportant = filteredTasks.where((task) => !task.isUrgent && task.isImportant).toList();
        final urgentNotImportant = filteredTasks.where((task) => task.isUrgent && !task.isImportant).toList();
        final notUrgentNotImportant = filteredTasks.where((task) => !task.isUrgent && !task.isImportant).toList();

        return Column(
          children: [
            // Project filter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Filter by Project:',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<int?>(
                      value: _selectedProjectId,
                      hint: const Text('All Projects'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All Projects'),
                        ),
                        ...projectProvider.projects.map((project) => DropdownMenuItem<int?>(
                          value: project.id,
                          child: Text(project.name),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedProjectId = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Matrix
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header row
                    Row(
                      children: [
                        const SizedBox(width: 120), // Space for left labels
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'URGENT',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'NOT URGENT',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSecondaryContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // First row: Important tasks
                    Expanded(
                      child: Row(
                        children: [
                          // Left label
                          Container(
                            width: 120,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                'IMPORTANT',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Quadrant 1: Urgent & Important (Do)
                          Expanded(
                            child: _buildQuadrant(
                              context,
                              'DO',
                              'Urgent & Important',
                              urgentImportant,
                              Colors.red.shade100,
                              Colors.red.shade700,
                              taskProvider,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Quadrant 2: Not Urgent & Important (Schedule)
                          Expanded(
                            child: _buildQuadrant(
                              context,
                              'SCHEDULE',
                              'Not Urgent & Important',
                              notUrgentImportant,
                              Colors.green.shade100,
                              Colors.green.shade700,
                              taskProvider,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Second row: Not Important tasks
                    Expanded(
                      child: Row(
                        children: [
                          // Left label
                          Container(
                            width: 120,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                'NOT IMPORTANT',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Quadrant 3: Urgent & Not Important (Delegate)
                          Expanded(
                            child: _buildQuadrant(
                              context,
                              'DELEGATE',
                              'Urgent & Not Important',
                              urgentNotImportant,
                              Colors.yellow.shade100,
                              Colors.yellow.shade700,
                              taskProvider,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Quadrant 4: Not Urgent & Not Important (Eliminate)
                          Expanded(
                            child: _buildQuadrant(
                              context,
                              'ELIMINATE',
                              'Not Urgent & Not Important',
                              notUrgentNotImportant,
                              Colors.grey.shade100,
                              Colors.grey.shade700,
                              taskProvider,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuadrant(
    BuildContext context,
    String title,
    String subtitle,
    List<Task> tasks,
    Color backgroundColor,
    Color textColor,
    PersistentTaskProvider taskProvider,
  ) {
    return DragTarget<Task>(
      onAccept: (task) {
        // Update task's urgent/important status based on quadrant
        Task updatedTask;
        switch (title) {
          case 'DO':
            updatedTask = task.copyWith(isUrgent: true, isImportant: true);
            break;
          case 'SCHEDULE':
            updatedTask = task.copyWith(isUrgent: false, isImportant: true);
            break;
          case 'DELEGATE':
            updatedTask = task.copyWith(isUrgent: true, isImportant: false);
            break;
          case 'ELIMINATE':
            updatedTask = task.copyWith(isUrgent: false, isImportant: false);
            break;
          default:
            updatedTask = task;
        }
        taskProvider.updateTask(updatedTask);
      },
      builder: (context, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty;
        
        return Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: isDragOver ? backgroundColor.withOpacity(0.8) : backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDragOver ? textColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: textColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${tasks.length} tasks',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Tasks
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: textColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No tasks',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
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
                                  width: 200,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    task.title,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: TaskItem(task: task),
                              ),
                              child: TaskItem(task: task),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
