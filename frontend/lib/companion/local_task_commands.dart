import 'package:flutter/material.dart';

/// Deliberately transport-free: no web URL handler, listener or agent access.
/// A future authorized adapter can call this same bounded command vocabulary.
enum LocalTaskAction { start, finish }

class LocalTaskCommand {
  const LocalTaskCommand(this.action, this.taskId);
  final LocalTaskAction action;
  final int taskId;

  static LocalTaskCommand parse(String input) {
    final match =
        RegExp(r'^(start|finish) ([1-9][0-9]{0,8})$').firstMatch(input.trim());
    if (match == null) {
      throw const FormatException('Use start <task ID> or finish <task ID>');
    }
    return LocalTaskCommand(
        match[1] == 'start' ? LocalTaskAction.start : LocalTaskAction.finish,
        int.parse(match[2]!));
  }
}

class LocalTaskCommandDialog extends StatefulWidget {
  const LocalTaskCommandDialog({super.key, required this.run});
  final Future<void> Function(LocalTaskCommand) run;
  @override
  State<LocalTaskCommandDialog> createState() => _LocalTaskCommandDialogState();
}

class _LocalTaskCommandDialogState extends State<LocalTaskCommandDialog> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.run(LocalTaskCommand.parse(_controller.text));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is FormatException
              ? e.message
              : 'Task could not be saved. Please try again.';
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Local task command'),
        content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text(
                      'Start or finish an existing task by its #ID. Runs only here; no agent is connected.'),
                  const SizedBox(height: 16),
                  TextField(
                      controller: _controller,
                      autofocus: true,
                      enabled: !_busy,
                      decoration: InputDecoration(
                          labelText: 'Command',
                          hintText: 'start 1 or finish 1',
                          errorText: _error),
                      onSubmitted: (_) => _run()),
                ]))),
        actions: [
          TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: _busy ? null : _run,
              child: Text(_busy ? 'Saving…' : 'Run command'))
        ],
      );
}
