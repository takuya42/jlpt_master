import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/constants/app_urls.dart';
import '../../../../app/navigation/app_route.dart';
import '../../../../shared/presentation/widgets/app_background.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/theme_mode_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
    this.urlLauncher = launchUrl,
  });

  final Future<bool> Function(Uri url, {LaunchMode mode}) urlLauncher;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isDeletingAccount = false;
  bool _isLoggingOut = false;

  Future<void> _confirmLogOut() async {
    final shouldLogOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out\nログアウト'),
        content: const Text(
          'Are you sure you want to log out?\n'
          'ログアウトしますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel\nキャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log Out\nログアウト'),
          ),
        ],
      ),
    );

    if (shouldLogOut != true || !mounted) return;

    setState(() => _isLoggingOut = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (!mounted) return;
      context.go(AppRoute.home.path);
      messenger.showSnackBar(
        const SnackBar(content: Text('Logged out successfully.')),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to log out: $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Future<void> _openTermsOfService() async {
    final url = Uri.parse(AppUrls.termsOfService);
    debugPrint('Opening Terms of Service: $url');
    try {
      // The Terms page must open in Safari/the user's default browser rather
      // than an in-app browser, so externalApplication is intentional here.
      final opened = await widget.urlLauncher(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        debugPrint(
          'Failed to open Terms of Service: launchUrl returned false '
          '(url: $url, mode: ${LaunchMode.externalApplication}).',
        );
        _showTermsLaunchFailure();
      }
    } on Exception catch (error, stackTrace) {
      debugPrint(
        'Failed to open Terms of Service with launchUrl '
        '(url: $url, mode: ${LaunchMode.externalApplication}): $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      _showTermsLaunchFailure();
    }
  }

  void _showTermsLaunchFailure() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open Terms of Service.')),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse(AppUrls.privacyPolicy);
    debugPrint('Opening Privacy Policy: $url');
    try {
      // The Privacy Policy page must open in Safari/the user's default browser
      // rather than an in-app browser, so externalApplication is intentional.
      final opened = await widget.urlLauncher(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        debugPrint(
          'Failed to open Privacy Policy: launchUrl returned false '
          '(url: $url, mode: ${LaunchMode.externalApplication}).',
        );
        _showPrivacyPolicyLaunchFailure();
      }
    } on Exception catch (error, stackTrace) {
      debugPrint(
        'Failed to open Privacy Policy with launchUrl '
        '(url: $url, mode: ${LaunchMode.externalApplication}): $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      _showPrivacyPolicyLaunchFailure();
    }
  }

  void _showPrivacyPolicyLaunchFailure() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open Privacy Policy.')),
    );
  }

  Future<void> _openContactForm() async {
    final url = Uri.parse(AppUrls.contactForm);
    debugPrint('Opening Contact Form: $url');
    try {
      // The contact form must open in Safari/the user's default browser rather
      // than an in-app browser, so externalApplication is intentional here.
      final opened = await widget.urlLauncher(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        debugPrint(
          'Failed to open Contact Form: launchUrl returned false '
          '(url: $url, mode: ${LaunchMode.externalApplication}).',
        );
        _showContactFormLaunchFailure();
      }
    } on Exception catch (error, stackTrace) {
      debugPrint(
        'Failed to open Contact Form with launchUrl '
        '(url: $url, mode: ${LaunchMode.externalApplication}): $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      _showContactFormLaunchFailure();
    }
  }

  void _showContactFormLaunchFailure() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open Contact Form.')),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account\nアカウントを削除'),
        content: const Text(
          'Are you sure you want to permanently delete your account?\n'
          'This action cannot be undone.\n\n'
          'アカウントを完全に削除しますか？\n'
          'この操作は元に戻せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel\nキャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete\n削除'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    setState(() => _isDeletingAccount = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authRepositoryProvider).deleteCurrentUserAccount();
      if (!mounted) return;
      context.go(AppRoute.home.path);
      messenger.showSnackBar(
        const SnackBar(content: Text('Account deleted successfully.')),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to delete account: $error')),
      );
    } finally {
      if (mounted) setState(() => _isDeletingAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(actions: const [PremiumButton()]),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                children: [
                Text(
                  'Settings\n設定',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                const _AccountCard(),
                const SizedBox(height: 18),
                const _GoPremiumCard(),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _SettingsTile(icon: Icons.favorite_border, title: 'Favorite', subtitle: 'お気に入り', onTap: () => context.go(AppRoute.favorite.path)),
                        _SettingsTile(icon: Icons.flag_outlined, title: 'Learning Goal', subtitle: '学習目標', onTap: () => context.go(AppRoute.learningGoal.path)),
                        const _ThemeModeTile(),
                        _SettingsTile(
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          subtitle: '利用規約',
                          onTap: _openTermsOfService,
                        ),
                        _SettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'プライバシーポリシー',
                          onTap: _openPrivacyPolicy,
                        ),
                        _SettingsTile(
                          icon: Icons.support_agent_outlined,
                          title: 'Contact',
                          subtitle: 'お問い合わせ',
                          onTap: _openContactForm,
                        ),
                      ],
                    ),
                  ),
                ),
                if (ref.watch(authStateProvider).asData?.value != null) ...[
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.logout,
                            title: 'Log Out',
                            subtitle: 'ログアウト',
                            enabled: !_isLoggingOut && !_isDeletingAccount,
                            onTap: _confirmLogOut,
                          ),
                          const Divider(indent: 20, endIndent: 20),
                          _DeleteAccountTile(
                            isDeleting: _isDeletingAccount,
                            enabled: !_isLoggingOut,
                            onTap: _confirmDeleteAccount,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(currentUserProvider).asData?.value;
    final isSignedIn = user != null;
    final displayName = user?.displayName.trim();
    final email = user?.email.trim();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.go(AppRoute.login.path),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isSignedIn ? colorScheme.primaryContainer : colorScheme.secondaryContainer,
                foregroundColor: isSignedIn ? colorScheme.onPrimaryContainer : colorScheme.onSecondaryContainer,
                child: Icon(isSignedIn ? Icons.verified_user_outlined : Icons.account_circle_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSignedIn && displayName != null && displayName.isNotEmpty ? displayName : 'Account\nアカウント',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, height: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSignedIn
                          ? (email != null && email.isNotEmpty ? email : 'No email address\nメールアドレス未登録')
                          : 'Not signed in\nログインしていません',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoPremiumCard extends StatelessWidget {
  const _GoPremiumCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.go(AppRoute.premium.path),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: const Icon(Icons.workspace_premium_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Go Premium', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text('プレミアムにアップグレード', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedThemeMode = ref.watch(themeModeControllerProvider).asData?.value ?? ThemeMode.system;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Icon(Icons.dark_mode_outlined, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dark Mode', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  _themeModeSubtitle(selectedThemeMode),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.75)),
                ),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.settings_suggest_outlined)),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
                  ],
                  selected: {selectedThemeMode},
                  onSelectionChanged: (selection) async {
                    await ref.read(themeModeControllerProvider.notifier).setThemeMode(selection.first);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _themeModeSubtitle(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'Light\nライト',
      ThemeMode.dark => 'Dark\nダーク',
      ThemeMode.system => 'System\nシステム設定',
    };
  }
}

class _DeleteAccountTile extends StatelessWidget {
  const _DeleteAccountTile({
    required this.isDeleting,
    required this.enabled,
    required this.onTap,
  });

  final bool isDeleting;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: isDeleting
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.error),
            )
          : Icon(Icons.delete_forever_outlined, color: colorScheme.error),
      title: Text('Delete Account', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w700)),
      subtitle: Text('退会', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colorScheme.error)),
      trailing: Icon(Icons.chevron_right_rounded, color: colorScheme.error),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      enabled: enabled && !isDeleting,
      onTap: enabled && !isDeleting ? onTap : null,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.enabled = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75))),
      trailing: Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }
}
