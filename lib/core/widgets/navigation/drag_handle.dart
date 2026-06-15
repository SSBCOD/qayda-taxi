import 'package:flutter/material.dart';

/// The small pill grabber at the top of bottom sheets.
class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
