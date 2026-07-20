import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../app/navigation/app_route.dart';
import '../data/auth_repository.dart';
import 'providers/auth_providers.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    try {
      await action();
      if (context.mounted) context.go(AppRoute.home.path);
    } on AuthSignInCancelled {
      // Closing the provider's authorization sheet is not an error.
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: () => context.go(AppRoute.home.path), icon: const Icon(Icons.arrow_back_rounded))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(padding: const EdgeInsets.fromLTRB(28, 72, 28, 36), children: [
              const _LoginHeader(),
              const SizedBox(height: 48),
              _SocialSignInButton.google(onPressed: () => _run(context, ref, ref.read(authRepositoryProvider).signInWithGoogle)),
              const SizedBox(height: 14),
              if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                SignInWithAppleButton(
                  onPressed: () => _run(
                    context,
                    ref,
                    ref.read(authRepositoryProvider).signInWithApple,
                  ),
                  text: 'Continue with Apple',
                  height: 56,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                const SizedBox(height: 14),
              ],
              FilledButton.tonalIcon(
                onPressed: () => context.go(AppRoute.emailLogin.path),
                icon: const Icon(Icons.mail_outline_rounded),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                label: const Text('Continue with Email\nメールアドレスで続ける', textAlign: TextAlign.center),
              ),
              const SizedBox(height: 36),
              const _CreateAccountPrompt(),
            ]),
          ),
        ),
      ),
    );
  }
}

class EmailLoginPage extends ConsumerStatefulWidget {
  const EmailLoginPage({super.key});
  @override
  ConsumerState<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends ConsumerState<EmailLoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(email: _email.text, password: _password.text);
      if (mounted) context.go(AppRoute.home.path);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _resetPassword() async {
    final email = await showDialog<String>(context: context, builder: (_) => _PasswordResetDialog(initialEmail: _email.text));
    if (email == null || email.trim().isEmpty) return;
    await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent. / 再設定メールを送信しました。')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoute.home.path);
          }
        },
      ),
      title: const Text('Email Login / メールログイン'),
    ),
    body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: ListView(padding: const EdgeInsets.all(24), children: [
      _AuthTextField(controller: _email, label: 'Email', japaneseLabel: 'メールアドレス', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next),
      const SizedBox(height: 16),
      _AuthTextField(controller: _password, label: 'Password', japaneseLabel: 'パスワード', icon: Icons.lock_outline_rounded, obscureText: true, textInputAction: TextInputAction.done),
      const SizedBox(height: 28),
      FilledButton(onPressed: _loading ? null : _signIn, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)), child: const Text('Sign In\nログイン', textAlign: TextAlign.center)),
      const SizedBox(height: 24),
      TextButton(onPressed: _resetPassword, child: const Text('Forgot Password?\nパスワードを忘れた場合', textAlign: TextAlign.center)),
    ])))));
}

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); _confirm.dispose(); super.dispose(); }
  Future<void> _create() async {
    if (_password.text != _confirm.text) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match.'))); return; }
    setState(() => _loading = true);
    try { await ref.read(authRepositoryProvider).createUserWithEmailAndPassword(displayName: _name.text, email: _email.text, password: _password.text); if (mounted) context.go(AppRoute.home.path); }
    catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString()))); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(leading: IconButton(onPressed: () => context.canPop() ? context.pop() : context.go(AppRoute.login.path), icon: const Icon(Icons.arrow_back_rounded)), title: const Text('Create Account')), body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: ListView(padding: const EdgeInsets.fromLTRB(24, 28, 24, 36), children: [
    Text('Create Account\n新規登録', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.2)),
    const SizedBox(height: 32),
    _AuthTextField(controller: _name, label: 'Display Name', japaneseLabel: '表示名', icon: Icons.badge_outlined, textInputAction: TextInputAction.next), const SizedBox(height: 16),
    _AuthTextField(controller: _email, label: 'Email', japaneseLabel: 'メールアドレス', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next), const SizedBox(height: 16),
    _AuthTextField(controller: _password, label: 'Password', japaneseLabel: 'パスワード', icon: Icons.lock_outline_rounded, obscureText: true, textInputAction: TextInputAction.next), const SizedBox(height: 16),
    _AuthTextField(controller: _confirm, label: 'Confirm Password', japaneseLabel: 'パスワード確認', icon: Icons.verified_user_outlined, obscureText: true, textInputAction: TextInputAction.done),
    const SizedBox(height: 28), _AuthActionButton(onPressed: _loading ? null : _create, loading: _loading, icon: Icons.person_add_alt_1_rounded, label: 'Create Account', japaneseLabel: 'アカウントを作成'),
    const SizedBox(height: 36), const _SignInPrompt(),
  ])))));
}


class _AuthActionButton extends StatelessWidget { const _AuthActionButton({required this.onPressed, required this.loading, required this.icon, required this.label, required this.japaneseLabel}); final VoidCallback? onPressed; final bool loading; final IconData icon; final String label, japaneseLabel; @override Widget build(BuildContext context)=>FilledButton.tonalIcon(onPressed: onPressed, icon: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(icon), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), label: Text('$label\n$japaneseLabel', textAlign: TextAlign.center)); }

class _PasswordResetDialog extends StatefulWidget { const _PasswordResetDialog({required this.initialEmail}); final String initialEmail; @override State<_PasswordResetDialog> createState() => _PasswordResetDialogState(); }

class _PasswordResetDialogState extends State<_PasswordResetDialog> { late final TextEditingController _controller = TextEditingController(text: widget.initialEmail); @override void dispose(){_controller.dispose(); super.dispose();} @override Widget build(BuildContext context)=>AlertDialog(title: const Text('Password Reset\nパスワード再設定'), content: _AuthTextField(controller: _controller, label: 'Email', japaneseLabel: 'メールアドレス', icon: Icons.mail_outline_rounded), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: ()=>Navigator.pop(context, _controller.text), child: const Text('Send'))]); }

class _LoginHeader extends StatelessWidget { const _LoginHeader(); @override Widget build(BuildContext context) { final theme = Theme.of(context); return Text('Welcome to JLPT Master\nJLPT Masterへようこそ', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.18)); } }
class _SocialSignInButton extends StatelessWidget { const _SocialSignInButton._({required this.label, required this.japaneseLabel, required this.logo, required this.onPressed, required this.backgroundColor, required this.foregroundColor, required this.borderColor}); factory _SocialSignInButton.google({required VoidCallback onPressed}) => _SocialSignInButton._(label: 'Continue with Google', japaneseLabel: 'Googleで続ける', logo: const _GoogleLogo(), onPressed: onPressed, backgroundColor: Colors.white, foregroundColor: const Color(0xFF1F1F1F), borderColor: const Color(0xFFDADCE0)); final String label, japaneseLabel; final Widget logo; final VoidCallback onPressed; final Color backgroundColor, foregroundColor, borderColor; @override Widget build(BuildContext context)=>FilledButton(onPressed: onPressed, style: FilledButton.styleFrom(backgroundColor: backgroundColor, foregroundColor: foregroundColor, minimumSize: const Size.fromHeight(56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: borderColor))), child: Stack(alignment: Alignment.center, children: [Align(alignment: Alignment.centerLeft, child: logo), Text('$label\n$japaneseLabel', textAlign: TextAlign.center)])); }
class _AuthTextField extends StatelessWidget { const _AuthTextField({required this.controller, required this.label, required this.japaneseLabel, required this.icon, this.keyboardType, this.obscureText = false, this.textInputAction}); final TextEditingController controller; final String label, japaneseLabel; final IconData icon; final TextInputType? keyboardType; final bool obscureText; final TextInputAction? textInputAction; @override Widget build(BuildContext context)=>TextField(controller: controller, keyboardType: keyboardType, obscureText: obscureText, textInputAction: textInputAction, decoration: InputDecoration(labelText: '$label / $japaneseLabel', prefixIcon: Icon(icon), filled: true, contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18), constraints: const BoxConstraints(minHeight: 56), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))); }
class _CreateAccountPrompt extends StatelessWidget { const _CreateAccountPrompt(); @override Widget build(BuildContext context)=>Column(children: [const Text('Don\'t have an account?\nアカウントをお持ちでないですか？', textAlign: TextAlign.center), TextButton(onPressed: () => context.go(AppRoute.register.path), child: const Text('Create Account\n新規登録', textAlign: TextAlign.center))]); }
class _SignInPrompt extends StatelessWidget { const _SignInPrompt(); @override Widget build(BuildContext context)=>Column(children: [const Text('Already have an account?\nすでにアカウントをお持ちですか？', textAlign: TextAlign.center), TextButton(onPressed: () => context.go(AppRoute.login.path), child: const Text('Sign In\nログイン', textAlign: TextAlign.center))]); }
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 24,
    child: CustomPaint(painter: _GoogleLogoPainter()),
  );
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.19;
    final oval = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(oval.deflate(strokeWidth / 2), -0.22, 1.62, false,
        paint..color = const Color(0xFF4285F4));
    canvas.drawArc(oval.deflate(strokeWidth / 2), 1.40, 1.04, false,
        paint..color = const Color(0xFF34A853));
    canvas.drawArc(oval.deflate(strokeWidth / 2), 2.44, 1.00, false,
        paint..color = const Color(0xFFFBBC05));
    canvas.drawArc(oval.deflate(strokeWidth / 2), 3.44, 1.26, false,
        paint..color = const Color(0xFFEA4335));
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint
        ..color = const Color(0xFF4285F4)
        ..strokeCap = StrokeCap.square,
    );
    canvas.drawArc(
      oval.deflate(strokeWidth / 2),
      -math.pi / 18,
      math.pi / 2,
      false,
      paint..strokeCap = StrokeCap.butt,
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter oldDelegate) => false;
}
