import 'dart:async';
import 'package:flutter/material.dart';

/// A tiny, original victory dance, bundled so completing tasks works offline.
///
/// The overlay never takes focus or intercepts a click. Reduced-motion users
/// receive the same confirmation without creating an animated image stream.
class CompletionCelebration extends StatefulWidget {
  const CompletionCelebration({super.key, required this.onComplete});

  static const gifAsset = 'assets/animations/task_complete_dance.gif';
  static const duration = Duration(milliseconds: 2600);

  final VoidCallback onComplete;

  @override
  State<CompletionCelebration> createState() => _CompletionCelebrationState();
}

class _CompletionCelebrationState extends State<CompletionCelebration> {
  Timer? _dismiss;

  @override
  void initState() {
    super.initState();
    _dismiss = Timer(CompletionCelebration.duration, () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _dismiss?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      child: Semantics(
        liveRegion: true,
        label: 'Task completed. Great job!',
        child: ExcludeSemantics(
          child: LayoutBuilder(builder: (context, constraints) {
            // A completion can still be visible while the user collapses the
            // companion. Keep the message inside its 84px compact header.
            final compact = constraints.maxHeight < 180;
            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: compact ? 12 : 18),
                child: Material(
                  color: const Color(0xFF20242C),
                  borderRadius: BorderRadius.circular(20),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!reduceMotion && !compact) ...[
                          Image.asset(
                            CompletionCelebration.gifAsset,
                            key: const ValueKey('completion-gif'),
                            width: 168,
                            height: 112,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                            excludeFromSemantics: true,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              height: 112,
                              child: Icon(Icons.celebration_rounded,
                                  color: Color(0xFFB8F280), size: 48),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: Color(0xFFB8F280), size: 20),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text('Task complete!',
                                  style: TextStyle(
                                      color: Color(0xFFF4F6FA),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        if (!reduceMotion && !compact) ...[
                          const SizedBox(height: 4),
                          const Text('Tiny task. Big dance.',
                              style: TextStyle(
                                  color: Color(0xFFC1C7D2), fontSize: 11)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
