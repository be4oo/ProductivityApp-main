import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A local, procedural celebration: no network, modal or external GIF asset.
class CompletionCelebration extends StatefulWidget {
  const CompletionCelebration({super.key, required this.onComplete});
  final VoidCallback onComplete;
  @override
  State<CompletionCelebration> createState() => _CompletionCelebrationState();
}

class _CompletionCelebrationState extends State<CompletionCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  Timer? _dismiss;
  bool? _reduceMotion;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    _animation.stop();
    if (!reduceMotion) _animation.forward(from: 0);
    _dismiss?.cancel();
    _dismiss = Timer(const Duration(milliseconds: 1600), widget.onComplete);
  }

  @override
  void dispose() {
    _dismiss?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Semantics(
          liveRegion: true,
          label: 'Task completed. Great job!',
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              final progress = _animation.value;
              return Stack(
                children: [
                  if (!_reduceMotion!)
                    Positioned.fill(
                      child: CustomPaint(
                          key: const ValueKey('completion-confetti'),
                          painter: _ConfettiPainter(progress)),
                    ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Opacity(
                        opacity: _reduceMotion!
                            ? 1
                            : (progress < .8 ? 1 : (1 - progress) / .2),
                        child: Material(
                          color: const Color(0xFFB8F280),
                          borderRadius: BorderRadius.circular(24),
                          elevation: 4,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Color(0xFF14161B), size: 22),
                                SizedBox(width: 8),
                                Text('Task complete! 🎉',
                                    style: TextStyle(
                                        color: Color(0xFF14161B),
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress);
  final double progress;
  static const colors = [
    Color(0xFFB8F280),
    Color(0xFFFFD166),
    Color(0xFFBDA0FF),
    Color(0xFF6EDCE0)
  ];
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var i = 0; i < 32; i++) {
      final angle = (i / 32) * math.pi * 2;
      final speed = 70 + (i % 5) * 24;
      final x = size.width / 2 + math.cos(angle) * speed * progress;
      final y =
          42 + math.sin(angle) * speed * progress + 145 * progress * progress;
      paint.color = colors[i % colors.length].withValues(alpha: 1 - progress);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + progress * 5);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(-3, -2, 6, 4), const Radius.circular(1)),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
