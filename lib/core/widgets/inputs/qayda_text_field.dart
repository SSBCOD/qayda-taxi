import 'package:flutter/material.dart';

/// Standard Qayda input: off-white fill, 1px black border on focus.
class QaydaTextField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  const QaydaTextField({
    super.key,
    this.hint,
    this.controller,
    this.keyboardType,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(hintText: hint, prefixIcon: prefixIcon),
    );
  }
}
