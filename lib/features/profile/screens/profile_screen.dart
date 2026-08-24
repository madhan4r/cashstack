import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_config.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/buttons/app_outlined_button.dart';
import '../../../core/widgets/cards/app_list_tile.dart';
import '../../../core/widgets/feedback/app_bottom_sheet.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../../../services/snackbar_service.dart';
import '../../auth/providers/auth_controller.dart';
import '../widgets/edit_name_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUpdatingAvatar = false;
  String? _failedAvatarUrl;

  Future<void> _handleEditName(String currentName) async {
    final newName = await showEditNameSheet(context: context, currentName: currentName);
    if (newName == null || !mounted) return;

    final result = await ref
        .read(authControllerProvider.notifier)
        .updateProfile(fullName: newName);
    if (!mounted) return;

    result.when(
      ok: (_) => ref.read(snackbarServiceProvider).showSuccess('Name updated'),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  Future<void> _handleAvatarTap(bool hasAvatar) async {
    final action = await showAppBottomSheet<_AvatarAction>(
      context: context,
      title: 'Profile Picture',
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.of(context).pop(_AvatarAction.pickFromGallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.of(context).pop(_AvatarAction.pickFromCamera),
          ),
          if (hasAvatar)
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Remove photo'),
              onTap: () => Navigator.of(context).pop(_AvatarAction.remove),
            ),
        ],
      ),
    );
    if (action == null || !mounted) return;

    switch (action) {
      case _AvatarAction.pickFromGallery:
        await _pickAndUploadAvatar(ImageSource.gallery);
      case _AvatarAction.pickFromCamera:
        await _pickAndUploadAvatar(ImageSource.camera);
      case _AvatarAction.remove:
        await _removeAvatar();
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (error) {
      if (!mounted) return;
      ref
          .read(snackbarServiceProvider)
          .showError(
            source == ImageSource.camera
                ? "Couldn't access the camera"
                : "Couldn't open the gallery",
          );
      return;
    }
    if (picked == null || !mounted) return;

    setState(() => _isUpdatingAvatar = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .uploadAvatar(picked.path);
    if (!mounted) return;
    setState(() => _isUpdatingAvatar = false);

    result.when(
      ok: (_) => ref.read(snackbarServiceProvider).showSuccess('Profile picture updated'),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  Future<void> _removeAvatar() async {
    setState(() => _isUpdatingAvatar = true);
    final result = await ref.read(authControllerProvider.notifier).removeAvatar();
    if (!mounted) return;
    setState(() => _isUpdatingAvatar = false);

    result.when(
      ok: (_) => ref.read(snackbarServiceProvider).showSuccess('Profile picture removed'),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final avatarUrl = user?.avatarUrl;
    final avatarLoadFailed = avatarUrl != null && avatarUrl == _failedAvatarUrl;

    return Scaffold(
      appBar: const CashStackAppBar(title: 'Profile', showBackButton: false),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: GestureDetector(
              onTap: _isUpdatingAvatar
                  ? null
                  : () => _handleAvatarTap(avatarUrl != null),
              child: Hero(
                tag: 'profile-avatar',
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: context.colors.primaryContainer,
                      backgroundImage: avatarUrl != null && !avatarLoadFailed
                          ? CachedNetworkImageProvider('${AppConfig.apiOrigin}$avatarUrl')
                          : null,
                      onBackgroundImageError: avatarUrl != null && !avatarLoadFailed
                          ? (_, _) {
                              // Falls back to the person icon instead of a
                              // silently blank circle (see profile-picture
                              // "uploaded but not showing" report).
                              if (mounted && _failedAvatarUrl != avatarUrl) {
                                setState(() => _failedAvatarUrl = avatarUrl);
                              }
                            }
                          : null,
                      child: _isUpdatingAvatar
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : (avatarUrl == null || avatarLoadFailed)
                          ? Icon(
                              Icons.person_outline,
                              size: 36,
                              color: context.colors.onPrimaryContainer,
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.colors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.colors.surface, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 14,
                          color: context.colors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? '—',
            style: context.textStyles.titleLarge,
            textAlign: TextAlign.center,
          ),
          Text(
            user?.email ?? '',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AppListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: 'Edit Name',
            subtitle: user?.fullName,
            onTap: () => _handleEditName(user?.fullName ?? ''),
          ),
          AppListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: 'Change Password',
            onTap: () => context.push(AppRoutes.changePassword),
          ),
          AppListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: 'Send Feedback',
            subtitle: 'Report a bug or share a suggestion',
            onTap: () => context.push(AppRoutes.feedback),
          ),
          const SizedBox(height: 24),
          AppOutlinedButton(
            label: 'Log out',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

enum _AvatarAction { pickFromGallery, pickFromCamera, remove }
