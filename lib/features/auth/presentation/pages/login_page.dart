import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _continueWithGoogle() {}

  void _continueWithApple() {}

  void _continueWithEmail() {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              children: [
                const SizedBox(height: 12),
                _LalaImagePlaceholder(colorScheme: colorScheme),
                const SizedBox(height: 26),
                Text(
                  'Welcome to JLPT Master',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'JLPT Masterへようこそ',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Learn Japanese with confidence.\n楽しく日本語を学びましょう。',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 36),
                _LoginButton(
                  icon: Icons.g_mobiledata_rounded,
                  english: 'Continue with Google',
                  japanese: 'Googleで続ける',
                  onPressed: _continueWithGoogle,
                ),
                const SizedBox(height: 12),
                _LoginButton(
                  icon: Icons.apple,
                  english: 'Continue with Apple',
                  japanese: 'Appleで続ける',
                  onPressed: _continueWithApple,
                ),
                const SizedBox(height: 12),
                _LoginButton(
                  icon: Icons.mail_outline_rounded,
                  english: 'Continue with Email',
                  japanese: 'メールアドレスで続ける',
                  onPressed: _continueWithEmail,
                ),
                const SizedBox(height: 32),
                Text(
                  'By continuing, you agree to our',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Terms of Use')),
                    TextButton(onPressed: () {}, child: const Text('Privacy Policy')),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '利用を続けることで利用規約・プライバシーポリシーに同意したものとします。',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LalaImagePlaceholder extends StatelessWidget {
  const _LalaImagePlaceholder({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Icon(
          Icons.pets_rounded,
          size: 72,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.icon,
    required this.english,
    required this.japanese,
    required this.onPressed,
  });

  final IconData icon;
  final String english;
  final String japanese;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  japanese,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  english,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
