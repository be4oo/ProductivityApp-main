import 'package:flutter/material.dart';
import 'dart:math' as math;

class CelebrationWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const CelebrationWidget({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late AnimationController _confettiController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _confettiAnimation;

  final List<String> _celebrationEmojis = ['🎉', '🎊', '✨', '🌟', '🏆', '👏', '🎈'];
  final List<Color> _celebrationColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _bounceAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _confettiController, curve: Curves.easeOut),
    );

    _startAnimation();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    await _fadeController.forward();
    _bounceController.forward();
    _confettiController.forward();
    
    // Auto-close after 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));
    await _fadeController.reverse();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnimation.value,
                    child: Container(
                      width: 300,
                      height: 200,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Confetti animation
                          SizedBox(
                            height: 60,
                            child: AnimatedBuilder(
                              animation: _confettiAnimation,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: ConfettiPainter(
                                    progress: _confettiAnimation.value,
                                    colors: _celebrationColors,
                                  ),
                                  size: const Size(200, 60),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Success icon
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Celebration text
                          Text(
                            'Task Completed!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Great job! 🎉',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  ConfettiPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42); // Fixed seed for consistent animation

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * progress;
      final color = colors[random.nextInt(colors.length)];
      
      paint.color = color.withOpacity(1.0 - progress);
      
      // Draw confetti pieces
      canvas.drawCircle(
        Offset(x, y),
        2 + random.nextDouble() * 3,
        paint,
      );
      
      // Draw some squares
      if (i % 3 == 0) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x + 20, y + 10),
            width: 4,
            height: 4,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
