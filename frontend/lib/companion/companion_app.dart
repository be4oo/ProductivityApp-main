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

const _ink = Color(0xFF14161B);
const _accent = Color(0xFFB8F280);

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

class CompanionShell extends StatelessWidget {
  const CompanionShell({super.key});
  @override
  Widget build(BuildContext context) {
    final window = context.watch<CompanionWindow>();
    final planner = window.mode == CompanionMode.planner;
    return CallbackShortcuts(
      bindings: {
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
              child: Container(
                width: planner ? double.infinity : 420,
                height: planner
                    ? double.infinity
                    : window.mode == CompanionMode.compact
                        ? 84
                        : 540,
                decoration: BoxDecoration(
                  color: _ink,
                  border: Border.all(color: Colors.white12),
                ),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(window.mode),
                  tween: Tween(
                    begin: MediaQuery.of(context).disableAnimations ? 1 : 0,
                    end: 1,
                  ),
                  duration: const Duration(milliseconds: 180),
                  builder: (_, opacity, child) =>
                      Opacity(opacity: opacity, child: child),
                  child: planner ? const PlannerView() : const CompanionPanel(),
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
                      padding: const EdgeInsets.symmetric(vertical: 18),
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
                              color: Colors.white54,
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
                        style: const TextStyle(color: Colors.white38),
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
                                color: Colors.white54,
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

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});
  final Task task;
  @override
  Widget build(BuildContext context) {
    final session = context.watch<FocusSession>();
    final selected = session.taskId == task.id;
    return Card(
      color: selected
          ? const Color(0xFF293326)
          : Colors.white.withValues(alpha: .035),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: IconButton(
          tooltip: 'Complete ${task.title}',
          icon: const Icon(Icons.radio_button_unchecked, size: 20),
          onPressed: () async {
            if (session.taskId == task.id && session.isRunning) {
              session.toggle();
            }
            await session.flush();
            if (!context.mounted) return;
            await context.read<PersistentTaskProvider>().toggleTaskCompletion(
                  task.id,
                );
            if (session.taskId == task.id) session.clear();
          },
        ),
        title: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
        subtitle: Text(
          '${task.estimatedTime > 0 ? task.estimatedTime : 25} min · ${task.priority.displayName}',
          style: const TextStyle(fontSize: 11, color: Colors.white38),
        ),
        trailing: IconButton(
          tooltip: 'Focus on ${task.title}',
          icon: Icon(
            selected && session.isRunning
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            color: selected ? _accent : Colors.white54,
          ),
          onPressed: () {
            session.select(task);
            session.toggle();
          },
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
  DateTime day = DateUtils.dateOnly(DateTime.now());
  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<PersistentTaskProvider>().tasks;
    final projects = context.watch<PersistentProjectProvider>().projects;
    final list = (projectId != null
        ? tasks.where((t) => t.projectId == projectId && isOpenTask(t)).toList()
        : allTasks
            ? tasks.where(isOpenTask).toList()
            : tasksForDay(tasks, day));
    final window = context.watch<CompanionWindow>();
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          if (constraints.maxWidth > 700)
            Container(
              width: 230,
              color: Colors.black26,
              padding: const EdgeInsets.all(18),
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
                    selected: projectId == null && !allTasks,
                    onTap: () => setState(() {
                      projectId = null;
                      allTasks = false;
                      day = DateUtils.dateOnly(DateTime.now());
                    }),
                  ),
                  ListTile(
                    leading: const Icon(Icons.inbox_outlined),
                    title: const Text('All tasks'),
                    selected: allTasks,
                    onTap: () => setState(() {
                      projectId = null;
                      allTasks = true;
                    }),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'PROJECTS',
                    style: TextStyle(
                      color: Colors.white38,
                      letterSpacing: 2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: projects
                          .map(
                            (project) => ListTile(
                              selected: projectId == project.id,
                              title: Text(project.name),
                              leading: const Icon(
                                Icons.circle,
                                size: 9,
                                color: _accent,
                              ),
                              onTap: () {
                                context
                                    .read<PersistentProjectProvider>()
                                    .selectProject(project.id);
                                setState(() {
                                  projectId = project.id;
                                  allTasks = false;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
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
                      color: Colors.white38,
                      fontSize: 10,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
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
                      value: projectId ?? (allTasks ? -2 : -1),
                      items: [
                        const DropdownMenuItem(value: -1, child: Text('Today')),
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
                          style: TextStyle(color: Colors.white38, fontSize: 12),
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
                          projectId != null
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
                  if (projectId == null && !allTasks)
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
                    '${list.length} tasks remaining',
                    style: const TextStyle(color: Colors.white38),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: list.isEmpty
                        ? const Center(
                            child: Text(
                              'Nothing scheduled. Leave a little breathing room.',
                              style: TextStyle(color: Colors.white38),
                            ),
                          )
                        : ListView(
                            children:
                                list.map((t) => _TaskRow(task: t)).toList(),
                          ),
                  ),
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
                          style: TextStyle(color: Colors.white38, fontSize: 11),
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
  if (session.taskId == task?.id && session.isRunning) session.toggle();
  await session.flush();
  if (!context.mounted) return;
  await showDialog<void>(
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
  if (session.taskId != null &&
      !provider.tasks.any((t) => t.id == session.taskId && isOpenTask(t))) {
    session.clear();
  }
}
