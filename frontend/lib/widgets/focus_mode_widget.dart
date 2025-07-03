import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/models.dart';
import '../providers/persistent_task_provider.dart';
import 'floating_timer_widget.dart';
import 'celebration_widget.dart';

class FocusModeWidget extends StatefulWidget {
  final Task task;

  const FocusModeWidget({Key? key, required this.task}) : super(key: key);

  @override
  State<FocusModeWidget> createState() => _FocusModeWidgetState();
}

class _FocusModeWidgetState extends State<FocusModeWidget>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 25 * 60; // 25 minutes in seconds
  int _totalSeconds = 25 * 60;
  int _sessionElapsed = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  int _completedPomodoros = 0;
  bool _isBreakTime = false;
  bool _isInMiniMode = false;
  
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set up timer based on estimated time or default to 25 minutes
    final estimatedMinutes = widget.task.estimatedTime ?? 25;
    _totalSeconds = estimatedMinutes * 60;
    _remainingSeconds = _totalSeconds;
    
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalSeconds),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    
    _progressController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _sessionElapsed++;
        });
      } else {
        _completeSession();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
    
    _timer?.cancel();
    _progressController.stop();
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
      _isRunning = true;
    });
    
    _progressController.forward();
    _startTimer();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _isBreakTime ? 5 * 60 : _totalSeconds;
      _sessionElapsed = 0;
    });
    
    _timer?.cancel();
    _progressController.reset();
  }

  void _completeSession() {
    _timer?.cancel();
    _progressController.reset();
    _saveProgress();
    
    setState(() {
      _isRunning = false;
      _isPaused = false;
      
      if (_isBreakTime) {
        // Break completed, back to work
        _isBreakTime = false;
        _remainingSeconds = _totalSeconds;
      } else {
        // Pomodoro completed
        _completedPomodoros++;
        _isBreakTime = true;
        _remainingSeconds = _completedPomodoros % 4 == 0 ? 15 * 60 : 5 * 60; // Long break every 4 pomodoros
      }
      _sessionElapsed = 0;
    });
    
    _showCelebration();
  }
  
  void _saveProgress() {
    final taskProvider = Provider.of<PersistentTaskProvider>(context, listen: false);
    final currentActualTime = widget.task.actualTime ?? 0;
    final additionalMinutes = (_sessionElapsed / 60).round();
    
    if (additionalMinutes > 0) {
      final updatedTask = Task(
        id: widget.task.id,
        title: widget.task.title,
        description: widget.task.description,
        column: widget.task.column,
        estimatedTime: widget.task.estimatedTime,
        actualTime: currentActualTime + additionalMinutes,
        priority: widget.task.priority,
        status: widget.task.status,
        reminderEnabled: widget.task.reminderEnabled,
        reminderOffset: widget.task.reminderOffset,
        isUrgent: widget.task.isUrgent,
        isImportant: widget.task.isImportant,
        projectId: widget.task.projectId,
        ownerId: widget.task.ownerId,
        createdAt: widget.task.createdAt,
        updatedAt: DateTime.now(),
        completedAt: widget.task.completedAt,
        dueDate: widget.task.dueDate,
        tags: widget.task.tags,
        estimatedPomodoros: widget.task.estimatedPomodoros,
      );
      taskProvider.updateTask(updatedTask);
    }
  }
  
  void _showCelebration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CelebrationWidget(
        onComplete: () {
          Navigator.of(context).pop();
          _showCompletionDialog();
        },
      ),
    );
  }

  void _skipToNext() {
    _timer?.cancel();
    _saveProgress();
    Navigator.of(context).pop();
  }

  void _enterMiniMode() {
    setState(() {
      _isInMiniMode = true;
    });
    
    Navigator.of(context).pop();
    
    // Show floating timer widget
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FloatingTimerWidget(
        task: widget.task,
        remainingSeconds: _remainingSeconds,
        isRunning: _isRunning,
        isPaused: _isPaused,
        onEnlarge: () {
          Navigator.of(context).pop();
          setState(() {
            _isInMiniMode = false;
          });
        },
        onComplete: () {
          Navigator.of(context).pop();
          _completeSession();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _skipToNext();
        },
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_isBreakTime ? 'Pomodoro Complete!' : 'Break Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isBreakTime ? Icons.celebration : Icons.work,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              _isBreakTime
                  ? 'Great job! Time for a ${_completedPomodoros % 4 == 0 ? 'long' : 'short'} break.'
                  : 'Break time is over. Ready to focus again?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Completed Pomodoros: $_completedPomodoros',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close focus mode
            },
            child: const Text('Finish'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startTimer();
            },
            child: Text(_isBreakTime ? 'Start Break' : 'Continue Working'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _isBreakTime ? 
        (_completedPomodoros % 4 == 0 ? 15 * 60 : 5 * 60) : 25 * 60;
    final progress = 1.0 - (_remainingSeconds / totalSeconds);
    
    return Scaffold(
      backgroundColor: _isBreakTime 
          ? Colors.green.shade50 
          : Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_isBreakTime ? 'Break Time' : 'Focus Mode'),
        backgroundColor: _isBreakTime ? Colors.green : null,
        foregroundColor: _isBreakTime ? Colors.white : null,
        actions: [
          IconButton(
            onPressed: _resetTimer,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Task Info
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      widget.task.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    if (widget.task.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.task.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Timer Circle
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRunning ? _pulseAnimation.value : 1.0,
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Circle
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        
                        // Progress Circle
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isBreakTime ? Colors.green : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        
                        // Timer Display
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(_remainingSeconds),
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _isBreakTime ? Colors.green : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isBreakTime ? 'Break Time' : 'Focus Time',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 48),
            
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning && !_isPaused)
                  FilledButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _isBreakTime ? Colors.green : null,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                
                if (_isRunning)
                  FilledButton.icon(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                
                if (_isPaused)
                  FilledButton.icon(
                    onPressed: _resumeTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _isBreakTime ? Colors.green : null,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                
                if (_isRunning || _isPaused) ...[
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: _completeSession,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Done'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Secondary Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Take a break (reset to break time)
                    setState(() {
                      _isBreakTime = true;
                      _remainingSeconds = 5 * 60;
                    });
                    _resetTimer();
                  },
                  icon: const Icon(Icons.coffee),
                  label: const Text('Take a Break'),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: _skipToNext,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip Task'),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: _enterMiniMode,
                  icon: const Icon(Icons.picture_in_picture),
                  label: const Text('Mini Mode'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Stats
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$_completedPomodoros',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Completed',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Theme.of(context).dividerColor,
                    ),
                    Column(
                      children: [
                        Text(
                          '${widget.task.estimatedPomodoros ?? 1}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        Text(
                          'Estimated',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
