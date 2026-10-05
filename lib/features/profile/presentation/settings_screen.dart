import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../data/user_repository.dart';
import 'avatar.dart';
import 'settings_controller.dart';

/// Экран `/settings`: редактирование имени и аватара.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(myProfileProvider);
    final settingsState = ref.watch(settingsControllerProvider);

    ref.listen(settingsControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.settingsSaveError)));
      } else if (previous?.isLoading == true &&
          !next.isLoading &&
          !next.hasError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: profileAsync.when(
        data: (profile) {
          if (profile != null && !_seeded) {
            _nameCtrl.text = profile.displayName;
            _seeded = true;
          }
          final displayName = profile?.displayName ?? '';
          final avatarUrl = profile?.avatarUrl;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: UserAvatar(
                  avatarUrl: avatarUrl,
                  name: displayName,
                  radius: 56,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: settingsState.isLoading
                        ? null
                        : () => _pickAvatar(),
                    icon: const Icon(Icons.photo_camera),
                    label: Text(l10n.settingsChangeAvatar),
                  ),
                  const SizedBox(width: 8),
                  if (avatarUrl != null && avatarUrl.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: settingsState.isLoading
                          ? null
                          : () => _confirmDeleteAvatar(),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.settingsRemoveAvatar),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameCtrl,
                maxLength: kMaxDisplayNameLen,
                decoration: InputDecoration(
                  labelText: l10n.settingsNameLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: settingsState.isLoading ? null : _saveName,
                  child: Text(l10n.settingsSaveName),
                ),
              ),
              const SizedBox(height: 24),
              if (settingsState.isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) =>
            Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    await ref.read(settingsControllerProvider.notifier).saveDisplayName(name);
  }

  Future<void> _pickAvatar() async {
    await ref.read(settingsControllerProvider.notifier).pickAndUploadAvatar();
  }

  Future<void> _confirmDeleteAvatar() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsRemoveAvatarTitle),
        content: Text(l10n.settingsRemoveAvatarConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.authCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.settingsRemoveAvatar),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(settingsControllerProvider.notifier).deleteAvatar();
    }
  }
}
