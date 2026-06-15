import 'package:flutter/material.dart';

/// Outlined secondary action (e.g. "Чат", "Звонок", "Пропустить").
/// 1px outline-variant border, 16px radius, optional leading icon.
class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
