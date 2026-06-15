import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

/// Boxed OTP entry. A single hidden field captures input while the boxes
/// render each digit — robust and keyboard-friendly for the verification flow.
class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpInput({
    super.key,
    this.length = 4,
    this.onChanged,
    this.onCompleted,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Responsive sizing: keep boxes within the available width so longer
    // codes (e.g. 6-digit OTP) never overflow on narrow phones.
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final totalGap = gap * (widget.length - 1);
        final boxWidth =
            ((maxWidth - totalGap) / widget.length).clamp(36.0, 56.0);
        final boxHeight = boxWidth * 64 / 56;

        return Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.length, (i) {
                final filled = i < _controller.text.length;
                final active = i == _controller.text.length;
                return Padding(
                  padding:
                      EdgeInsets.only(right: i == widget.length - 1 ? 0 : gap),
                  child: Container(
                    width: boxWidth,
                    height: boxHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadii.input),
                      border: Border.all(
                        color: active || filled
                            ? scheme.primary
                            : scheme.outlineVariant.withValues(alpha: 0.4),
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      filled ? _controller.text[i] : '',
                      style: AppTypography.headlineLg,
                    ),
                  ),
                );
              }),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: widget.length,
                  showCursor: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: _onChanged,
                  decoration: const InputDecoration(counterText: ''),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
