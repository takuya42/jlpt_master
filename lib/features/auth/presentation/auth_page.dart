import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_route.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoute.home.path);
  }

  void onGoogleSignIn() {
    // TODO: Implement Google sign-in.
  }

  void onAppleSignIn() {
    // TODO: Implement Apple sign-in.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const SizedBox.shrink(),
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => _handleBack(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 72, 28, 36),
              children: [
                const _LoginHeader(),
                const SizedBox(height: 48),
                _SocialSignInButton.google(onPressed: onGoogleSignIn),
                const SizedBox(height: 14),
                _SocialSignInButton.apple(onPressed: onAppleSignIn),
                const SizedBox(height: 36),
                const _CreateAccountPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  void onCreateAccount() {
    // TODO: Implement account creation.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(AppRoute.login.path);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              children: [
                Text(
                  'Create Account\n新規登録',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 32),
                const _AuthTextField(
                  label: 'Display Name',
                  japaneseLabel: '表示名',
                  icon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                const _AuthTextField(
                  label: 'Email',
                  japaneseLabel: 'メールアドレス',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                const _AuthTextField(
                  label: 'Password',
                  japaneseLabel: 'パスワード',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                const _AuthTextField(
                  label: 'Confirm Password',
                  japaneseLabel: 'パスワード確認',
                  icon: Icons.verified_user_outlined,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: onCreateAccount,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Create Account\nアカウントを作成', textAlign: TextAlign.center),
                ),
                const SizedBox(height: 36),
                const _SignInPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to JLPT Master\nJLPT Masterへようこそ',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Learn Japanese with confidence.\n楽しく日本語を学びましょう。',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.55,
          ),
        ),
      ],
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

  factory _SocialSignInButton.google({required VoidCallback onPressed}) => _SocialSignInButton._(
        label: 'Continue with Google',
        japaneseLabel: 'Googleで続ける',
        logo: const _GoogleLogo(),
        onPressed: onPressed,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F1F1F),
        borderColor: const Color(0xFFDADCE0),
      );

  factory _SocialSignInButton.apple({required VoidCallback onPressed}) => _SocialSignInButton._(
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
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(alignment: Alignment.centerLeft, child: logo),
          Text('$label\n$japaneseLabel', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.label,
    required this.japaneseLabel,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
  });

  final String label;
  final String japaneseLabel;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: '$label / $japaneseLabel',
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _CreateAccountPrompt extends StatelessWidget {
  const _CreateAccountPrompt();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          'Don\'t have an account?\nアカウントをお持ちでないですか？',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.45),
        ),
        TextButton(
          onPressed: () => context.go(AppRoute.register.path),
          child: const Text('Create Account\n新規登録', textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          'Already have an account?\nすでにアカウントをお持ちですか？',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.45),
        ),
        TextButton(
          onPressed: () => context.go(AppRoute.login.path),
          child: const Text('Sign In\nログイン', textAlign: TextAlign.center),
        ),
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
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
      ),
    );
  }
}
