import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInAnonymously() => _run(() => FirebaseAuth.instance.signInAnonymously());

  Future<void> _signInWithEmail() => _run(
        () => FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );

  Future<void> _run(Future<UserCredential> Function() action) async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await action();
      if (!mounted) return;
      setState(() => _message = 'Signed in successfully / ログインしました');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _message = error.message ?? error.code);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
              children: [
                const _LalaHero(),
                const SizedBox(height: 28),
                Text(
                  'Welcome to JLPT Master\nJLPT Masterへようこそ',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Learn Japanese with your new friend, Lala.\nララと一緒に楽しく日本語を学びましょう。',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                if (user != null) ...[
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: ListTile(
                      leading: const Icon(Icons.verified_user_outlined),
                      title: Text(user.email ?? 'Guest user'),
                      subtitle: Text(user.uid),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _SocialSignInButton.google(onPressed: _loading ? null : () {}),
                const SizedBox(height: 12),
                _SocialSignInButton.apple(onPressed: _loading ? null : () {}),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _signInWithEmail,
                  icon: const Icon(Icons.mail_outline_rounded),
                  label: const Text('Continue with Email'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _loading ? null : _signInAnonymously,
                  child: const Text('Continue as guest / ゲストで開始'),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_message!, textAlign: TextAlign.center),
                  ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    TextButton(
                      onPressed: _loading ? null : () {},
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LalaHero extends StatelessWidget {
  const _LalaHero();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.tertiaryContainer,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 22,
            right: 28,
            child: Icon(Icons.auto_awesome_rounded, color: colorScheme.primary.withValues(alpha: 0.45), size: 34),
          ),
          Positioned(
            bottom: 18,
            left: 24,
            child: Icon(Icons.favorite_rounded, color: colorScheme.tertiary.withValues(alpha: 0.28), size: 42),
          ),
          Image.asset(
            'assets/images/lala.png',
            height: 172,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(
              Icons.pets_rounded,
              size: 108,
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.76),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  const _SocialSignInButton._({
    required this.label,
    required this.logo,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  factory _SocialSignInButton.google({required VoidCallback? onPressed}) => _SocialSignInButton._(
        label: 'Continue with Google',
        logo: const _GoogleLogo(),
        onPressed: onPressed,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F1F1F),
        borderColor: const Color(0xFFDADCE0),
      );

  factory _SocialSignInButton.apple({required VoidCallback? onPressed}) => _SocialSignInButton._(
        label: 'Continue with Apple',
        logo: const Icon(Icons.apple, size: 24),
        onPressed: onPressed,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        borderColor: Colors.black,
      );

  final String label;
  final Widget logo;
  final VoidCallback? onPressed;
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
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
        disabledForegroundColor: foregroundColor.withValues(alpha: 0.5),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(alignment: Alignment.centerLeft, child: logo),
          Text(label),
        ],
      ),
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
