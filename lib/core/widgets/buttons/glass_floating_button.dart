import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_shadows.dart';

/// Circular glassmorphic floating button (map controls, back, etc.).
class GlassFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  const GlassFloatingButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: AppGlass.fillOf(Theme.of(context).brightness),
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: scheme.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
