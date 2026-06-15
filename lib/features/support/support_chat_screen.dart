import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/extensions/context_ext.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'application/support_chat_controller.dart';

/// Live support chat (Stitch `support_chat_bilingual`).
///
/// Agent «Aisulu», bilingual bubbles, fake auto-replies — no backend.
class SupportChatScreen extends ConsumerStatefulWidget {
  const SupportChatScreen({super.key});

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _inputCtrl.text;
    if (text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    ref.read(supportChatControllerProvider.notifier).send(text);
    _inputCtrl.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final chat = ref.watch(supportChatControllerProvider);

    ref.listen(supportChatControllerProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: _ChatAppBar(onBack: () => context.pop()),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                AppSpacing.md,
              ),
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Сегодня / Бүгін',
                      style: AppTypography.labelMd
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ...chat.messages.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: m.isFromUser
                        ? _OutgoingBubble(message: m)
                        : _IncomingBubble(message: m),
                  ),
                ),
                if (chat.agentTyping) const _TypingIndicator(),
              ],
            ),
          ),
          _ChatInputBar(
            controller: _inputCtrl,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  const _ChatAppBar({required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      height: preferredSize.height + topInset,
      padding: EdgeInsets.only(
        left: AppSpacing.page,
        top: topInset,
        right: AppSpacing.page,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.surfaceContainerHigh,
                child:
                    Icon(Icons.support_agent, color: scheme.primary, size: 26),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.surfaceContainerLowest,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.gutter),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aisulu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineMd,
                ),
                Text(
                  'Online / Онлайн',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}

class _IncomingBubble extends StatelessWidget {
  final ChatMessage message;
  const _IncomingBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final time = DateFormat('HH:mm').format(message.time);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: scheme.surfaceContainerHigh,
          child: Icon(Icons.support_agent, size: 16, color: scheme.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(AppRadii.card),
                    bottomLeft: Radius.circular(AppRadii.card),
                    bottomRight: Radius.circular(AppRadii.card),
                  ),
                ),
                child: Text(
                  message.text,
                  style: AppTypography.bodyMd,
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(time,
                    style: AppTypography.labelMd.copyWith(
                      fontSize: 10,
                      color: scheme.onSurfaceVariant,
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OutgoingBubble extends StatelessWidget {
  final ChatMessage message;
  const _OutgoingBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final time = DateFormat('HH:mm').format(message.time);
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadii.card),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(AppRadii.card),
                  bottomRight: Radius.circular(AppRadii.card),
                ),
              ),
              child: Text(
                message.text,
                overflow: TextOverflow.visible,
                style: AppTypography.bodyMd.copyWith(color: scheme.onPrimary),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time,
                    style: AppTypography.labelMd.copyWith(
                      fontSize: 10,
                      color: scheme.onSurfaceVariant,
                    )),
                const SizedBox(width: 4),
                Icon(Icons.done_all, size: 14, color: scheme.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        AppSpacing.md + bottom,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: scheme.surfaceContainerLow,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.attach_file),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Написать сообщение... / Хабарлама жазу...',
                filled: true,
                fillColor: scheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.button),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: scheme.primary,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: onSend,
              icon: Icon(Icons.send, color: scheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
