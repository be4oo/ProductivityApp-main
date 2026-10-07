import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/persistent_task_provider.dart';
import '../providers/persistent_project_provider.dart';
import '../widgets/task_dialog.dart';
import '../widgets/project_dialog.dart';
import 'companion_window.dart';
import 'focus_session.dart';
import 'completion_celebration.dart';
import 'glass_surface.dart';
import 'local_task_commands.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _ink = Color(0xFF172438);
const _accent = Color(0xFF90E8DC);

class CompanionApp extends StatelessWidget {
  const CompanionApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Blitzit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: _ink,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _accent,
            brightness: Brightness.dark,
          ),
          textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Inter'),
        ),
        home: const CompanionShell(),
      );
}

class CompanionShell extends StatefulWidget {
  const CompanionShell({super.key});
  @override
  State<CompanionShell> createState() => _CompanionShellState();
}

class _CompanionShellState extends State<CompanionShell> {
  int _celebration = 0;
  bool _celebrating = false;
  bool _opaque = false;
  bool _systemOpaque = false;
  static const _native = MethodChannel('blitzit/desktop');

  @override
  void initState() {
    super.initState();
    _loadAppearance();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _native.invokeMethod<void>('reportReady');
      } catch (_) {}
    });
    _native.setMethodCallHandler((call) async {
      if (call.method == 'accessibilityChanged' && mounted) {
        setState(() => _systemOpaque = call.arguments == true);
      }
    });
  }

  Future<void> _loadAppearance() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (mounted) {
        setState(
            () => _opaque = preferences.getBool('companion.opaque') ?? false);
      }
      final system =
          await _native.invokeMethod<bool>('reduceTransparency') ?? false;
      if (mounted) setState(() => _systemOpaque = system);
      await _native.invokeMethod<void>('setOpaque', _opaque);
    } catch (_) {/* Web/tests have no native appearance channel. */}
  }

  Future<void> toggleGlass() async {
    setState(() => _opaque = !_opaque);
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('companion.opaque', _opaque);
      await _native.invokeMethod<void>('setOpaque', _opaque);
    } catch (_) {/* The in-app contrast choice remains available. */}
  }

  @override
  void dispose() {
    _native.setMethodCallHandler(null);
    super.dispose();
  }

  void celebrate() {
    if (!mounted) return;
    setState(() {
      _celebration++;
      _celebrating = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final window = context.watch<CompanionWindow>();
    final planner = window.mode == CompanionMode.planner;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            _showLocalCommand(context, this),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            window.show(CompanionMode.compact),
        const SingleActivator(LogicalKeyboardKey.keyP, meta: true): () =>
            window.show(CompanionMode.planner),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
            alignment: Alignment.topCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(planner ? 0 : 24),
              child: SizedBox(
                width: planner ? double.infinity : 420,
                height: planner
                    ? double.infinity
                    : window.mode == CompanionMode.compact
                        ? 84
                        : 540,
                child: GlassSurface(
                  opaque: _opaque ||
                      _systemOpaque ||
                      MediaQuery.highContrastOf(context),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      TweenAnimationBuilder<double>(
                        key: ValueKey(window.mode),
                        tween: Tween(
                          begin:
                              MediaQuery.of(context).disableAnimations ? 1 : 0,
                          end: 1,
                        ),
                        duration: const Duration(milliseconds: 180),
                        builder: (_, opacity, child) =>
                            Opacity(opacity: opacity, child: child),
                        child: planner
                            ? const PlannerView()
                            : const CompanionPanel(),
                      ),
                      if (context
                                  .watch<PersistentTaskProvider>()
                                  .initializationError !=
                              null ||
                          context
                                  .watch<PersistentProjectProvider>()
                                  .initializationError !=
                              null)
                        const Positioned(
                            left: 12,
                            right: 12,
                            bottom: 4,
                            child: Text(
                                'Local storage unavailable. Changes cannot be saved.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFFFFD59C), fontSize: 11))),
                      if (_celebrating)
                        CompletionCelebration(
                          key: ValueKey(_celebration),
                          onComplete: () {
                            if (mounted) setState(() => _celebrating = false);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CompanionPanel extends StatelessWidget {
  const CompanionPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final window = context.watch<CompanionWindow>();
    final session = context.watch<FocusSession>();
    final provider = context.watch<PersistentTaskProvider>();
    final today = tasksForDay(provider.tasks, DateTime.now());
    final selected = provider.tasks
        .where((t) => t.id == session.taskId && isOpenTask(t))
        .firstOrNull;
    final expanded = window.mode == CompanionMode.expanded;
    return Column(
      children: [
        SizedBox(
          height: 82,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onPanStart: (_) => window.drag(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.bolt_rounded, color: _accent, size: 28),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: window.busy
                        ? null
                        : () => window.show(
                              expanded
                                  ? CompanionMode.compact
                                  : CompanionMode.expanded,
                            ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selected?.title ?? 'A little more focus',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (window.error ?? session.loggingError) != null
                                ? (window.error ?? session.loggingError)!
                                : selected == null
                                    ? '${today.length} tasks today · Click to open'
                                    : session.isRunning
                                        ? 'FOCUS IN PROGRESS'
                                        : 'READY WHEN YOU ARE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Text(
                  session.display,
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 19,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                IconButton(
                  tooltip: session.isRunning ? 'Pause focus' : 'Start focus',
                  onPressed: selected == null ? null : session.toggle,
                  icon: Icon(
                    session.isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: _accent,
                  ),
                ),
                IconButton(
                  tooltip: expanded ? 'Collapse companion' : 'Expand companion',
                  onPressed: window.busy
                      ? null
                      : () => window.show(
                            expanded
                                ? CompanionMode.compact
                                : CompanionMode.expanded,
                          ),
                  icon: Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Expanded(
            child: Column(
              children: [
                const Divider(height: 1, color: Colors.white12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 14, 12),
                  child: Row(
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${today.length}',
                        style: const TextStyle(color: Colors.white60),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Add task',
                        icon: const Icon(Icons.add),
                        onPressed: () => _editTask(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: today.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(28),
                            child: Text(
                              'A clear day.\nAdd a task with today’s due date to begin.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                height: 1.8,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: today.length,
                          itemBuilder: (context, index) =>
                              _TaskRow(task: today[index]),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: window.busy
                          ? null
                          : () => window.show(CompanionMode.planner),
                      icon: const Icon(Icons.open_in_full, size: 16),
                      label: const Text('Open planner'),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TaskRow extends StatefulWidget {
  const _TaskRow({required this.task});
  final Task task;
  @override
  State<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<_TaskRow> {
  bool _saving = false;
  Task get task => widget.task;
  @override
  Widget build(BuildContext context) {
    final session = context.watch<FocusSession>();
    final selected = session.taskId == task.id;
    final completed = isCompletedTask(task);
    return Card(
      color: selected
          ? const Color(0xB52A5862)
          : Colors.white.withValues(alpha: .065),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: Colors.white.withValues(alpha: selected ? .2 : .07))),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: IconButton(
          tooltip: '${completed ? 'Reopen' : 'Complete'} ${task.title}',
          icon: Icon(
              completed ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: completed ? _accent : null),
          onPressed: _saving
              ? null
              : () async {
                  final id = task.id;
                  final tasks = context.read<PersistentTaskProvider>();
                  final shell =
                      context.findAncestorStateOfType<_CompanionShellState>();
                  final messenger = ScaffoldMessenger.of(context);
                  setState(() => _saving = true);
                  try {
                    if (session.taskId == id && session.isRunning) {
                      session.toggle();
                    }
                    await session.flush();
                    if (!mounted) return;
                    await tasks.toggleTaskCompletion(id);
                    if (shell?.mounted != true) return;
                    if (session.taskId == id) session.clear();
                    if (!completed) shell!.celebrate();
                  } catch (_) {
                    if (messenger.mounted) {
                      messenger.showSnackBar(const SnackBar(
                        content:
                            Text('Task could not be saved. Please try again.'),
                      ));
                    }
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
        ),
        title: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
        subtitle: Text(
          '${task.estimatedTime > 0 ? task.estimatedTime : 25} min · ${task.priority.displayName} · #${task.id}',
          style: const TextStyle(fontSize: 11, color: Colors.white60),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOpenTask(task))
              IconButton(
                tooltip: 'Focus on ${task.title}',
                icon: Icon(
                  selected && session.isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: selected ? _accent : Colors.white70,
                ),
                onPressed: () {
                  session.select(task);
                  session.toggle();
                },
              ),
            PopupMenuButton<String>(
              tooltip: 'Task actions',
              iconSize: 18,
              onSelected: (action) async {
                if (action == 'edit') {
                  await _editTask(context, task);
                } else if (action == 'delete' && context.mounted) {
                  await _deleteTask(context, task);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit task')),
                PopupMenuItem(value: 'delete', child: Text('Delete task')),
              ],
            ),
          ],
        ),
        onTap: () => _editTask(context, task),
      ),
    );
  }
}

class PlannerView extends StatefulWidget {
  const PlannerView({super.key});
  @override
  State<PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends State<PlannerView> {
  int? projectId;
  bool allTasks = false;
  bool completed = false;
  DateTime day = DateUtils.dateOnly(DateTime.now());
  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<PersistentTaskProvider>().tasks;
    final projects = context.watch<PersistentProjectProvider>().projects;
    final list = (completed
        ? tasks.where(isCompletedTask).toList()
        : projectId != null
            ? tasks
                .where((t) => t.projectId == projectId && !isCompletedTask(t))
                .toList()
            : allTasks
                ? tasks.where((t) => !isCompletedTask(t)).toList()
                : tasksForDay(tasks, day));
    final window = context.watch<CompanionWindow>();
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (constraints.maxWidth > 700)
            Container(
              width: 230,
              color: Colors.black26,
              padding: const EdgeInsets.all(18),
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Row(children: [
                      Icon(Icons.bolt_rounded, color: _accent, size: 30),
                      SizedBox(width: 8),
                      Expanded(
                          child: Text('Blitzit',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w700))),
                    ]),
                  ),
                  ListTile(
                    leading: const Icon(Icons.wb_sunny_outlined),
                    title: const Text('Today'),
                    selected: projectId == null && !allTasks && !completed,
                    onTap: () => setState(() {
                      projectId = null;
                      allTasks = false;
                      completed = false;
                      day = DateUtils.dateOnly(DateTime.now());
                    }),
                  ),
                  ListTile(
                    leading: const Icon(Icons.inbox_outlined),
                    title: const Text('All tasks'),
                    selected: allTasks && !completed,
                    onTap: () => setState(() {
                      projectId = null;
                      allTasks = true;
                      completed = false;
                    }),
                  ),
                  ListTile(
                    leading: const Icon(Icons.task_alt),
                    title: const Text('Completed'),
                    selected: completed,
                    onTap: () => setState(() {
                      completed = true;
                      allTasks = false;
                      projectId = null;
                    }),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'PROJECTS',
                    style: TextStyle(
                      color: Colors.white60,
                      letterSpacing: 2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: projects
                        .map(
                          (project) => ListTile(
                            selected: projectId == project.id,
                            contentPadding: EdgeInsets.zero,
                            minLeadingWidth: 12,
                            horizontalTitleGap: 10,
                            title: Text(project.name,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: PopupMenuButton<String>(
                              tooltip: 'Project actions for ${project.name}',
                              iconSize: 18,
                              onSelected: (action) async {
                                if (action == 'edit') {
                                  await showDialog(
                                      context: context,
                                      builder: (_) =>
                                          ProjectDialog(project: project));
                                } else {
                                  await _deleteProject(context, project);
                                  if (context.mounted &&
                                      !context
                                          .read<PersistentProjectProvider>()
                                          .projects
                                          .any((p) => p.id == project.id)) {
                                    setState(() {
                                      projectId = null;
                                      allTasks = true;
                                      completed = false;
                                    });
                                  }
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'edit', child: Text('Edit project')),
                                PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete project')),
                              ],
                            ),
                            leading: Icon(
                              Icons.circle,
                              size: 9,
                              color: _projectColor(project.color),
                            ),
                            onTap: () {
                              context
                                  .read<PersistentProjectProvider>()
                                  .selectProject(project.id);
                              setState(() {
                                projectId = project.id;
                                allTasks = false;
                                completed = false;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  TextButton.icon(
                    onPressed: () => _showLocalCommand(context),
                    icon: const Icon(Icons.terminal),
                    label: const Text('Local commands'),
                  ),
                  TextButton.icon(
                    onPressed: () => context
                        .findAncestorStateOfType<_CompanionShellState>()
                        ?.toggleGlass(),
                    icon: const Icon(Icons.blur_on),
                    label: const Text('Glass / solid appearance'),
                  ),
                  TextButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const ProjectDialog(),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('New project'),
                  ),
                  const Text(
                    'LOCAL WORKSPACE\nSaved on this device',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      height: 1.8,
                    ),
                  ),
                ],
              )),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(constraints.maxWidth > 700 ? 40 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (constraints.maxWidth <= 700)
                    DropdownButton<int>(
                      isExpanded: true,
                      value: completed ? -4 : projectId ?? (allTasks ? -2 : -1),
                      items: [
                        const DropdownMenuItem(value: -1, child: Text('Today')),
                        const DropdownMenuItem(
                            value: -4, child: Text('Completed')),
                        const DropdownMenuItem(
                          value: -2,
                          child: Text('All tasks'),
                        ),
                        ...projects.map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        ),
                        const DropdownMenuItem(
                          value: -3,
                          child: Text('+ New project'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == -3) {
                          showDialog(
                            context: context,
                            builder: (_) => const ProjectDialog(),
                          );
                          return;
                        }
                        setState(() {
                          projectId =
                              value != null && value >= 0 ? value : null;
                          allTasks = value == -2;
                          completed = value == -4;
                          if (value == -1) {
                            day = DateUtils.dateOnly(DateTime.now());
                          }
                        });
                      },
                    ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Make room for what matters.',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Return to companion',
                        onPressed: window.busy
                            ? null
                            : () => window.show(CompanionMode.compact),
                        icon: const Icon(Icons.picture_in_picture_alt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          completed
                              ? 'Completed'
                              : projectId != null
                                  ? projects
                                          .where((p) => p.id == projectId)
                                          .firstOrNull
                                          ?.name ??
                                      'Project'
                                  : allTasks
                                      ? 'All tasks'
                                      : 'Your day, in focus.',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () =>
                            _editTask(context, null, projectId, day),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New task'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (projectId == null && !allTasks && !completed)
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Previous day',
                          onPressed: () => setState(
                            () => day = DateTime(
                              day.year,
                              day.month,
                              day.day - 1,
                            ),
                          ),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
                        ),
                        IconButton(
                          tooltip: 'Next day',
                          onPressed: () => setState(
                            () => day = DateTime(
                              day.year,
                              day.month,
                              day.day + 1,
                            ),
                          ),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  Text(
                    completed
                        ? '${list.length} tasks completed'
                        : '${list.length} tasks remaining',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Text(
                              completed
                                  ? 'Completed tasks will appear here.'
                                  : 'Nothing scheduled. Leave a little breathing room.',
                              style: const TextStyle(color: Colors.white60),
                            ),
                          )
                        : ListView(
                            children:
                                list.map((t) => _TaskRow(task: t)).toList(),
                          ),
                  ),
                  if (context.watch<FocusSession>().loggingError != null)
                    TextButton.icon(
                        onPressed: () =>
                            context.read<FocusSession>().retryLogging(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry saving focus time')),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: _accent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        context.watch<FocusSession>().display,
                        style: const TextStyle(color: _accent),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Your focus stays with you when you switch views',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _editTask(
  BuildContext context, [
  Task? task,
  int? projectId,
  DateTime? day,
]) async {
  final provider = context.read<PersistentTaskProvider>();
  final projects = context.read<PersistentProjectProvider>();
  final session = context.read<FocusSession>();
  final editingId = task?.id;
  if (session.taskId == editingId && session.isRunning) session.toggle();
  await session.flush();
  if (!context.mounted) return;
  // Flushing focus may replace the stored task with newly logged actual time.
  // Open the editor from that current record rather than the row's snapshot.
  if (editingId != null) {
    task = provider.tasks.where((value) => value.id == editingId).firstOrNull;
    if (task == null) return;
  }
  final shell = context.findAncestorStateOfType<_CompanionShellState>();
  final newlyCompleted = await showDialog<bool>(
    context: context,
    builder: (_) => TaskDialog(
      task: task,
      projectId: task?.projectId ??
          projectId ??
          projects.projects.firstOrNull?.id ??
          1,
      initialDueDate: day ?? DateTime.now(),
    ),
  );
  if (newlyCompleted == true) shell?.celebrate();
  if (shell?.mounted != true) return;
  if (session.taskId != null &&
      !provider.tasks.any((t) => t.id == session.taskId && isOpenTask(t))) {
    session.clear();
  }
}

Future<void> _deleteTask(BuildContext context, Task task) async {
  final tasks = context.read<PersistentTaskProvider>();
  final session = context.read<FocusSession>();
  final messenger = ScaffoldMessenger.of(context);
  final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Delete task?'),
            content: Text('Delete “${task.title}”? This cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete task'))
            ],
          ));
  if (approved != true) return;
  try {
    if (session.taskId == task.id && session.isRunning) session.toggle();
    await session.flush();
    await tasks.deleteTask(task.id);
    if (session.taskId == task.id) session.clear();
  } catch (_) {
    if (messenger.mounted) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Task could not be deleted. Please try again.')));
    }
  }
}

Future<void> _deleteProject(BuildContext context, Project project) async {
  final projects = context.read<PersistentProjectProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Delete project?'),
            content: Text(
                'Delete “${project.name}”? Its tasks will stay in All tasks and can be moved to another project.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete project'))
            ],
          ));
  if (approved != true) return;
  try {
    await projects.deleteProject(project.id);
  } catch (_) {
    if (messenger.mounted) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Project could not be deleted. Please try again.')));
    }
  }
}

Future<void> _showLocalCommand(BuildContext context,
    [_CompanionShellState? owner]) async {
  final window = context.read<CompanionWindow>();
  if (window.mode == CompanionMode.compact) {
    await window.show(CompanionMode.expanded);
    if (!context.mounted) return;
  }
  final tasks = context.read<PersistentTaskProvider>();
  final session = context.read<FocusSession>();
  final shell =
      owner ?? context.findAncestorStateOfType<_CompanionShellState>();
  await showDialog<void>(
      context: context,
      builder: (_) => LocalTaskCommandDialog(run: (command) async {
            final task = tasks.tasks
                .where((task) => task.id == command.taskId)
                .firstOrNull;
            if (task == null) {
              throw const FormatException('No task has that ID');
            }
            if (!isOpenTask(task)) {
              throw const FormatException('Choose an open task');
            }
            if (command.action == LocalTaskAction.start) {
              session.select(task);
              if (!session.isRunning) session.toggle();
            } else {
              if (session.taskId == task.id && session.isRunning) {
                session.toggle();
              }
              await session.flush();
              await tasks.toggleTaskCompletion(task.id);
              if (shell?.mounted != true) return;
              if (session.taskId == task.id) session.clear();
              shell?.celebrate();
            }
          }));
}

Color _projectColor(String value) {
  const named = {
    'green': Color(0xFF81C784),
    'blue': Color(0xFF64B5F6),
    'red': Color(0xFFE57373),
    'purple': Color(0xFFBA68C8),
    'orange': Color(0xFFFFB74D),
    'yellow': Color(0xFFFFD54F),
    'pink': Color(0xFFF06292),
    'teal': Color(0xFF4DB6AC)
  };
  if (named.containsKey(value.toLowerCase())) {
    return named[value.toLowerCase()]!;
  }
  final hex = value.replaceFirst('#', '');
  final parsed = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
  return parsed == null ? _accent : Color(parsed);
}
