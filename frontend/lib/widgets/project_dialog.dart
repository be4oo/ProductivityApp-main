import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/persistent_project_provider.dart';

class ProjectDialog extends StatefulWidget {
  final Project? project;

  const ProjectDialog({super.key, this.project});

  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _color = '#2196F3';
  bool _isLoading = false;
  String? _saveError;

  final List<String> _colors = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#607D8B', // Blue Grey
    '#795548', // Brown
    '#FF5722', // Deep Orange
    '#009688', // Teal
    '#E91E63', // Pink
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.project?.description ?? '',
    );
    if (widget.project != null) {
      final color = _hexToColor(widget.project!.color);
      _color =
          '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (_isLoading) return;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project name')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _saveError = null;
    });

    try {
      final projectProvider = Provider.of<PersistentProjectProvider>(
        context,
        listen: false,
      );

      final project = Project(
        id: widget.project?.id ?? 0,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _color,
        ownerId: widget.project?.ownerId ?? 1,
        createdAt: widget.project?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      if (widget.project == null) {
        await projectProvider.createProject(project);
      } else {
        await projectProvider.updateProject(project);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saveError = 'Project wasn’t saved. Please try again.';
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

  Color _hexToColor(String hex) {
    const namedColors = {
      'blue': Colors.blue,
      'green': Colors.green,
      'purple': Colors.purple,
      'orange': Colors.orange,
      'red': Colors.red,
      'teal': Colors.teal,
      'pink': Colors.pink,
      'indigo': Colors.indigo,
    };
    final value = hex.trim();
    if (namedColors.containsKey(value.toLowerCase())) {
      return namedColors[value.toLowerCase()]!;
    }
    final digits = value.startsWith('#') ? value.substring(1) : value;
    final parsed = int.tryParse(digits, radix: 16);
    if (parsed != null && (digits.length == 6 || digits.length == 8)) {
      return Color(digits.length == 6 ? parsed | 0xFF000000 : parsed);
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _hexToColor(_color),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.project == null
                          ? Icons.create_new_folder
                          : Icons.edit,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.project == null
                            ? 'Create Project'
                            : 'Edit Project',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project Name
                        TextField(
                          enabled: !_isLoading,
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Project Name',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
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
                        const SizedBox(height: 24),

                        // Color Selection
                        Text(
                          'Project Color',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _colors.map((color) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _color = color;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _hexToColor(color),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _color == color
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _hexToColor(color)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _color == color
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_saveError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                padding: const EdgeInsets.all(24),
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
                      onPressed: _isLoading ? null : _saveProject,
                      style: FilledButton.styleFrom(
                        backgroundColor: _hexToColor(_color),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.project == null ? 'Create' : 'Update'),
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
