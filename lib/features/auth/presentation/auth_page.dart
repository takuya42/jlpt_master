import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void onGoogleSignIn() {
    // TODO: Implement Google sign-in.
  }

  void onAppleSignIn() {
    // TODO: Implement Apple sign-in.
  }

  void onEmailSignIn() {
    // TODO: Implement email sign-in.
  }

  void onGuestSignIn() {
    // TODO: Implement guest sign-in.
  }

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
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
              children: [
                const _WelcomeHeader(),
                const SizedBox(height: 36),
                _AuthCard(
                  child: Column(
                    children: [
                      _SocialSignInButton.google(onPressed: onGoogleSignIn),
                      const SizedBox(height: 12),
                      _SocialSignInButton.apple(onPressed: onAppleSignIn),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: onEmailSignIn,
                        icon: const Icon(Icons.mail_outline_rounded),
                        label: const _BilingualButtonLabel(
                          englishLabel: 'Continue with Email',
                          japaneseLabel: 'メールアドレスで続ける',
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: onGuestSignIn,
                        icon: const Icon(Icons.person_outline_rounded),
                        label: const _BilingualButtonLabel(
                          englishLabel: 'Continue as Guest',
                          japaneseLabel: 'ゲストで始める',
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const _CreateAccountPrompt(),
                const SizedBox(height: 28),
                Text(
                  'By continuing, you agree to our',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                const _PolicyLinks(),
                const SizedBox(height: 12),
                Text(
                  '利用を続けることで\n利用規約・プライバシーポリシー\nに同意したものとします。',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.school_rounded,
            color: colorScheme.onPrimaryContainer,
            size: 36,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to JLPT Master\nJLPT Masterへようこそ',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Learn Japanese with confidence.\n楽しく日本語を学びましょう。',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  const _SocialSignInButton._({
    required this.label,
    required this.japaneseLabel,
    required this.logo,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  factory _SocialSignInButton.google({required VoidCallback onPressed}) =>
      _SocialSignInButton._(
        label: 'Continue with Google',
        japaneseLabel: 'Googleで続ける',
        logo: const _GoogleLogo(),
        onPressed: onPressed,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F1F1F),
        borderColor: const Color(0xFFDADCE0),
      );

  factory _SocialSignInButton.apple({required VoidCallback onPressed}) =>
      _SocialSignInButton._(
        label: 'Continue with Apple',
        japaneseLabel: 'Appleで続ける',
        logo: const Icon(Icons.apple, size: 24),
        onPressed: onPressed,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        borderColor: Colors.black,
      );

  final String label;
  final String japaneseLabel;
  final Widget logo;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
        textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(alignment: Alignment.centerLeft, child: logo),
          _BilingualButtonLabel(
            englishLabel: label,
            japaneseLabel: japaneseLabel,
          ),
        ],
      ),
    );
  }
}

class _BilingualButtonLabel extends StatelessWidget {
  const _BilingualButtonLabel({
    required this.englishLabel,
    required this.japaneseLabel,
  });

  final String englishLabel;
  final String japaneseLabel;

  @override
  Widget build(BuildContext context) {
    return Text('$englishLabel\n$japaneseLabel', textAlign: TextAlign.center);
  }
}

class _CreateAccountPrompt extends StatelessWidget {
  const _CreateAccountPrompt();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          'Don\'t have an account?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(onPressed: () {}, child: const Text('Create Account')),
        const SizedBox(height: 4),
        Text(
          'アカウントをお持ちでないですか？',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(onPressed: () {}, child: const Text('新規登録')),
      ],
    );
  }
}

class _PolicyLinks extends StatelessWidget {
  const _PolicyLinks();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        TextButton(onPressed: () {}, child: const Text('Terms of Use')),
        TextButton(onPressed: () {}, child: const Text('Privacy Policy')),
      ],
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
    );
  }
}
