import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/persistent_project_provider.dart';
import '../providers/persistent_task_provider.dart';

class ProjectSidebar extends StatelessWidget {
  const ProjectSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer<PersistentProjectProvider>(
      builder: (context, projectProvider, child) {
        if (projectProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Projects',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showAddProjectDialog(context),
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Project',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: projectProvider.projects.length,
                itemBuilder: (context, index) {
                  final project = projectProvider.projects[index];
                  final isSelected = projectProvider.selectedProjectId == project.id;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      selected: isSelected,
                      selectedTileColor: colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(int.parse(project.color.replaceAll('#', '0xFF'))),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        project.name,
                        style: TextStyle(
                          color: isSelected 
                            ? colorScheme.onPrimaryContainer 
                            : colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: project.description != null
                        ? Text(
                            project.description!,
                            style: TextStyle(
                              color: isSelected 
                                ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                                : colorScheme.onSurface.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                      trailing: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: isSelected 
                            ? colorScheme.onPrimaryContainer 
                            : colorScheme.onSurface.withOpacity(0.7),
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _showEditProjectDialog(context, project);
                              break;
                            case 'delete':
                              _showDeleteProjectDialog(context, project);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        projectProvider.selectProject(project.id);
                        // Reload tasks for the selected project
                        Provider.of<PersistentTaskProvider>(context, listen: false)
                            .loadTasks();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    Color selectedColor = Colors.blue;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'Enter project name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter project description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Color: '),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      // Simple color picker
                      final colors = [
                        Colors.blue, Colors.red, Colors.green, Colors.orange,
                        Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
                      ];
                      
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Choose Color'),
                          content: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: colors.map((color) => GestureDetector(
                              onTap: () {
                                setState(() => selectedColor = color);
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: selectedColor == color 
                                    ? Border.all(color: Colors.black, width: 2)
                                    : null,
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Provider.of<PersistentProjectProvider>(context, listen: false)
                      .createProject(
                    Project(
                      id: 0, // Will be assigned by the provider
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim().isEmpty 
                        ? null 
                        : descriptionController.text.trim(),
                      color: selectedColor.toString(),
                      ownerId: 1,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, project) {
    // TODO: Implement edit project dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit project coming soon!')),
    );
  }

  void _showDeleteProjectDialog(BuildContext context, project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"? This will also delete all tasks in this project.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Provider.of<PersistentProjectProvider>(context, listen: false)
                  .deleteProject(project.id);
              Navigator.pop(context);
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
}
