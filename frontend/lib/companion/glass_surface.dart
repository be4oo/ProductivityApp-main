import 'dart:ui';
import 'package:flutter/material.dart';

/// Readable tinted glass. Native macOS vibrancy supplies the desktop backdrop;
/// this layer supplies consistent contrast in web previews and opaque mode.
class GlassSurface extends StatelessWidget {
  const GlassSurface({super.key, required this.child, required this.opaque});
  final Widget child;
  final bool opaque;
  @override
  Widget build(BuildContext context) {
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: opaque
              ? const [Color(0xFF202A3E), Color(0xFF101D2D)]
              : const [Color(0xC728364C), Color(0xD4172935), Color(0xD421203C)],
          stops: opaque ? null : const [0, .6, 1],
        ),
        border: Border.all(color: const Color(0x33E0F2FF)),
      ),
      child: child,
    );
    return opaque
        ? surface
        : BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: surface,
          );
  }
}
