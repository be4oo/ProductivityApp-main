import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/models.dart';
import '../providers/persistent_task_provider.dart';

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
  bool _isRunning = false;
  bool _isPaused = false;
  int _completedPomodoros = 0;
  bool _isBreakTime = false;
  
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
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
        });
      } else {
        _completePomodoro();
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
      _remainingSeconds = _isBreakTime ? 5 * 60 : 25 * 60;
    });
    
    _timer?.cancel();
    _progressController.reset();
  }

  void _completePomodoro() {
    _timer?.cancel();
    _progressController.reset();
    
    setState(() {
      _isRunning = false;
      _isPaused = false;
      
      if (_isBreakTime) {
        // Break completed, back to work
        _isBreakTime = false;
        _remainingSeconds = 25 * 60;
      } else {
        // Pomodoro completed
        _completedPomodoros++;
        _isBreakTime = true;
        _remainingSeconds = _completedPomodoros % 4 == 0 ? 15 * 60 : 5 * 60; // Long break every 4 pomodoros
      }
    });
    
    _showCompletionDialog();
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
