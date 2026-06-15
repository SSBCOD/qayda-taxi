import 'package:flutter/material.dart';

/// Small pill used for statuses like "В СЕТИ", "ОНЛАЙН", "En Route".
class StatusPill extends StatelessWidget {
  final String text;
  final Color? background;
  final Color? foreground;

  const StatusPill({
    super.key,
    required this.text,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = background ?? scheme.primary;
    final fg = foreground ?? scheme.onPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
      ),
    );
  }
}
