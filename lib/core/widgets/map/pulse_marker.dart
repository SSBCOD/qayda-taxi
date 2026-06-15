import 'package:flutter/material.dart';

/// Animated pulsing location marker (user position / pickup point).
/// Uses [AppColors.locationBlue] by default to match DESIGN.md.
class PulseMarker extends StatefulWidget {
  final Color color;
  final double size;
  final Widget? child;

  const PulseMarker({
    super.key,
    this.color = const Color(0xFF007AFF),
    this.size = 16,
    this.child,
  });

  @override
  State<PulseMarker> createState() => _PulseMarkerState();
}

class _PulseMarkerState extends State<PulseMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 3,
      height: widget.size * 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              return Container(
                width: widget.size * (1 + t * 2),
                height: widget.size * (1 + t * 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: (1 - t) * 0.4),
                ),
              );
            },
          ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
