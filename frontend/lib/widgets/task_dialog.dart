import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/persistent_task_provider.dart';
import '../providers/persistent_project_provider.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final int projectId;
  final DateTime? initialDueDate;

  const TaskDialog({
    super.key,
    this.task,
    required this.projectId,
    this.initialDueDate,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  late TextEditingController _pomodorosController;
  late int _projectId;
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.todo;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  int _estimatedPomodoros = 1;
  bool _isLoading = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _projectId = widget.task?.projectId ?? widget.projectId;
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
    _pomodorosController = TextEditingController(
      text: _estimatedPomodoros.toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _pomodorosController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );

    if (mounted && date != null) {
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

    if (mounted && time != null) {
      setState(() {
        _dueTime = time;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_isLoading) return;
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _saveError = null;
    });

    try {
      final taskProvider = Provider.of<PersistentTaskProvider>(
        context,
        listen: false,
      );
      final projects = context.read<PersistentProjectProvider>().projects;
      final projectId =
          projects.any((project) => project.id == _projectId) ? _projectId : 0;
      final isCompleted =
          _status == TaskStatus.completed || _status == TaskStatus.done;
      final wasCompleted = widget.task?.status == TaskStatus.completed ||
          widget.task?.status == TaskStatus.done;

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
            projectId: projectId,
            ownerId: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            dueDate: finalDueDate,
            tags: tags,
            estimatedPomodoros: _estimatedPomodoros,
          ),
        );
      } else {
        // Merge editable fields onto the latest record, preserving focus time
        // or other non-editor fields updated while the dialog was open.
        final latest = taskProvider.tasks
            .where((task) => task.id == widget.task!.id)
            .firstOrNull;
        if (latest == null) throw StateError('Task no longer exists');
        await taskProvider.updateTask(
          latest.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _priority,
            status: _status,
            clearCompletedAt:
                _status != TaskStatus.completed && _status != TaskStatus.done,
            column:
                (_status == TaskStatus.completed || _status == TaskStatus.done)
                    ? 'Done'
                    : latest.column == 'Done'
                        ? 'To Do'
                        : latest.column,
            completedAt:
                (_status == TaskStatus.completed || _status == TaskStatus.done)
                    ? latest.completedAt ?? DateTime.now()
                    : null,
            dueDate: finalDueDate,
            estimatedPomodoros: _estimatedPomodoros,
            tags: tags,
            estimatedTime: _estimatedPomodoros * 25,
            projectId: projectId,
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(isCompleted && !wasCompleted);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saveError = 'Task wasn’t saved. Please try again.';
        });
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
    final projects = context.watch<PersistentProjectProvider>().projects;
    final selectedProjectId =
        projects.any((project) => project.id == _projectId) ? _projectId : 0;
    return PopScope(
      canPop: !_isLoading,
      child: Dialog(
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
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    )),
                    IconButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        TextField(
                          enabled: !_isLoading,
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Task Title',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<int>(
                          value: selectedProjectId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Project',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 0,
                              child: Text('No project'),
                            ),
                            ...projects.where((project) => project.id != 0).map(
                                  (project) => DropdownMenuItem(
                                    value: project.id,
                                    child: Text(project.name,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _projectId = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextField(
                          enabled: !_isLoading,
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
                            if (value != null) {
                              setState(() => _priority = value);
                            }
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
                                    _dueDate?.toString().split(' ')[0] ??
                                        'Not set',
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
                                enabled: !_isLoading,
                                decoration: const InputDecoration(
                                  labelText: 'Estimated Pomodoros',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.timer),
                                ),
                                keyboardType: TextInputType.number,
                                controller: _pomodorosController,
                                onChanged: (value) {
                                  final pomodoros = int.tryParse(value) ?? 1;
                                  setState(() {
                                    _estimatedPomodoros =
                                        pomodoros.clamp(1, 20);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '≈ ${(_estimatedPomodoros * 25)} min',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                          enabled: !_isLoading,
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
              ),

              if (_saveError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      _saveError!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
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
      ),
    );
  }
}
