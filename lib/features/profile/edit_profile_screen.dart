import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../features/auth/application/auth_controller.dart';

/// Universal "edit personal data" screen for both passenger and driver.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;
  late final TextEditingController _emailCtrl;
  bool _saving = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authControllerProvider);
    _firstCtrl = TextEditingController(text: auth.firstName);
    _lastCtrl  = TextEditingController(text: auth.lastName);
    _emailCtrl = TextEditingController(text: auth.email);
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _firstCtrl.text.trim().isNotEmpty && _changed && !_saving;

  void _onAnyChange() => setState(() => _changed = true);

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      await ref.read(authControllerProvider.notifier).saveProfile(
            firstName: _firstCtrl.text,
            lastName:  _lastCtrl.text,
            email:     _emailCtrl.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные сохранены'),
          duration: Duration(seconds: 2),
        ),
      );
      context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = ref.watch(authControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: QaydaAppBar(
        title: 'Личные данные',
        subtitle: 'Жеке деректер',
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.page, vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar ─────────────────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: scheme.surfaceContainer,
                      child: Text(
                        auth.firstName.isNotEmpty
                            ? auth.firstName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.purple,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.purple,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: scheme.surface, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            size: 15, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Нажмите для смены фото',
                  style: TextStyle(
                      color: scheme.onSurfaceVariant, fontSize: 12),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Fields ─────────────────────────────────────────────────
              _Field(
                controller: _firstCtrl,
                label: 'ИМЯ *',
                hint: 'Арман',
                icon: Icons.person_outline,
                onChanged: (_) => _onAnyChange(),
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _lastCtrl,
                label: 'ФАМИЛИЯ',
                hint: 'Муратов',
                icon: Icons.person_outline,
                onChanged: (_) => _onAnyChange(),
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _emailCtrl,
                label: 'EMAIL',
                hint: 'example@mail.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _onAnyChange(),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Phone (read-only) ────────────────────────────────────────
              _ReadOnlyField(
                label: 'ТЕЛЕФОН',
                value: auth.phone ?? '—',
                icon: Icons.phone_outlined,
                hint: 'Изменить номер невозможно',
              ),
              const SizedBox(height: AppSpacing.lg),

              if (!_changed)
                Center(
                  child: Text(
                    'Измените данные чтобы сохранить',
                    style: TextStyle(
                        color: scheme.onSurfaceVariant, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, 0, AppSpacing.page, AppSpacing.md),
          child: _saving
              ? const Center(child: CircularProgressIndicator())
              : PrimaryActionButton(
                  label: 'Сохранить изменения',
                  onPressed: _canSave ? _save : null,
                ),
        ),
      ),
    );
  }
}

// ── Field widgets ─────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.name,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTypography.headlineMd.copyWith(color: scheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.purple, size: 20),
            hintStyle: AppTypography.headlineMd
                .copyWith(color: scheme.onSurfaceVariant),
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.input),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.input),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.input),
              borderSide:
                  const BorderSide(color: AppColors.purple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String hint;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadii.input),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, color: scheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: AppTypography.headlineMd
                          .copyWith(color: scheme.onSurface),
                    ),
                    Text(
                      hint,
                      style: TextStyle(
                          color: scheme.onSurfaceVariant, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.lock_outline,
                  size: 16, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }
}
