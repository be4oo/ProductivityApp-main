import 'package:flutter/material.dart';
import 'dart:async';
import '../models/models.dart';

class FloatingTimerWidget extends StatefulWidget {
  final Task task;
  final int remainingSeconds;
  final bool isRunning;
  final bool isPaused;
  final VoidCallback onEnlarge;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const FloatingTimerWidget({
    Key? key,
    required this.task,
    required this.remainingSeconds,
    required this.isRunning,
    required this.isPaused,
    required this.onEnlarge,
    required this.onComplete,
    required this.onSkip,
  }) : super(key: key);

  @override
  State<FloatingTimerWidget> createState() => _FloatingTimerWidgetState();
}

class _FloatingTimerWidgetState extends State<FloatingTimerWidget> {
  Timer? _timer;
  int _currentSeconds = 0;
  int _sessionElapsed = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isOvertime = false;
  Offset _position = const Offset(100, 100);

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.remainingSeconds;
    _isRunning = widget.isRunning;
    _isPaused = widget.isPaused;
    
    if (_isRunning && !_isPaused) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        setState(() {
          _currentSeconds--;
          _sessionElapsed++;
        });
      } else {
        setState(() {
          _isOvertime = true;
          _currentSeconds--;
          _sessionElapsed++;
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      
      if (_isPaused) {
        _timer?.cancel();
      } else {
        _startTimer();
      }
    });
  }

  String _formatTime(int seconds) {
    final isNegative = seconds < 0;
    final absSeconds = seconds.abs();
    final minutes = absSeconds ~/ 60;
    final secs = absSeconds % 60;
    final prefix = isNegative ? '-' : '';
    return '$prefix${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position = _position + details.delta;
          });
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isOvertime 
                  ? Colors.red.shade100 
                  : (isDark ? Colors.grey.shade800 : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isOvertime 
                    ? Colors.red 
                    : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.task.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: _isOvertime ? Colors.red.shade700 : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onEnlarge,
                      icon: const Icon(Icons.open_in_full),
                      iconSize: 20,
                    ),
                  ],
                ),
                
                // Timer display
                Text(
                  _formatTime(_currentSeconds),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isOvertime ? Colors.red : theme.colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _togglePause,
                      icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onComplete,
                      icon: const Icon(Icons.check_circle),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onSkip,
                      icon: const Icon(Icons.skip_next),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
