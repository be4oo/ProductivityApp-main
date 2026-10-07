import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/persistent_task_provider.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final int projectId;
  final DateTime? initialDueDate;

  const TaskDialog({
    Key? key,
    this.task,
    required this.projectId,
    this.initialDueDate,
  }) : super(key: key);

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.todo;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  int _estimatedPomodoros = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.initialDueDate;
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.task?.tags?.join(', ') ?? '',
    );

    if (widget.task != null) {
      _priority = widget.task!.priority;
      _status = widget.task!.status;
      _dueDate = widget.task!.dueDate;
      _estimatedPomodoros = widget.task!.estimatedPomodoros ?? 1;

      if (widget.task!.dueDate != null) {
        _dueTime = TimeOfDay.fromDateTime(widget.task!.dueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _dueTime = time;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final taskProvider = Provider.of<PersistentTaskProvider>(
        context,
        listen: false,
      );

      DateTime? finalDueDate;
      if (_dueDate != null && _dueTime != null) {
        finalDueDate = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime!.hour,
          _dueTime!.minute,
        );
      } else if (_dueDate != null) {
        finalDueDate = _dueDate;
      }

      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      if (widget.task == null) {
        // Create new task
        await taskProvider.createTask(
          Task(
            id: 0, // Will be assigned by the provider
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            column:
                (_status == TaskStatus.completed || _status == TaskStatus.done)
                    ? 'Done'
                    : 'To Do',
            completedAt:
                (_status == TaskStatus.completed || _status == TaskStatus.done)
                    ? DateTime.now()
                    : null,
            estimatedTime: _estimatedPomodoros * 25,
            actualTime: 0,
            priority: _priority,
            status: _status,
            reminderEnabled: false,
            reminderOffset: 0,
            isUrgent: false,
            isImportant: false,
            projectId: widget.projectId,
            ownerId: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            dueDate: finalDueDate,
            tags: tags,
            estimatedPomodoros: _estimatedPomodoros,
          ),
        );
      } else {
        // Update existing task
        await taskProvider.updateTask(
          widget.task!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _priority,
            status: _status,
            clearCompletedAt:
                _status != TaskStatus.completed && _status != TaskStatus.done,
            column:
                (_status == TaskStatus.completed || _status == TaskStatus.done)
                    ? 'Done'
                    : widget.task!.column == 'Done'
                        ? 'To Do'
                        : widget.task!.column,
            completedAt:
                (_status == TaskStatus.completed || _status == TaskStatus.done)
                    ? widget.task!.completedAt ?? DateTime.now()
                    : null,
            dueDate: finalDueDate,
            estimatedPomodoros: _estimatedPomodoros,
            tags: tags,
            estimatedTime: _estimatedPomodoros * 25,
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving task: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.task == null ? Icons.add_task : Icons.edit,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Text(
                    widget.task == null ? 'Create Task' : 'Edit Task',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  )),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<TaskPriority>(
                      value: _priority,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: TaskPriority.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _priority = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskStatus>(
                      value: _status,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: TaskStatus.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Due Date and Time
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Due Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _dueDate?.toString().split(' ')[0] ?? 'Not set',
                                style: TextStyle(
                                  color: _dueDate == null
                                      ? Theme.of(context).hintColor
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: _selectTime,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Due Time',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.access_time),
                              ),
                              child: Text(
                                _dueTime?.format(context) ?? 'Not set',
                                style: TextStyle(
                                  color: _dueTime == null
                                      ? Theme.of(context).hintColor
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Estimated Pomodoros
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Estimated Pomodoros',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.timer),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                              text: _estimatedPomodoros.toString(),
                            ),
                            onChanged: (value) {
                              final pomodoros = int.tryParse(value) ?? 1;
                              setState(() {
                                _estimatedPomodoros = pomodoros.clamp(1, 20);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '≈ ${(_estimatedPomodoros * 25)} min',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma-separated)',
                        border: OutlineInputBorder(),
                        hintText: 'work, urgent, meeting',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _isLoading ? null : _saveTask,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.task == null ? 'Create' : 'Update'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
