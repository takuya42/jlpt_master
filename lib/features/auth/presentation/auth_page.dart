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

  Future<void> _createAccount() => _run(
        () => FirebaseAuth.instance.createUserWithEmailAndPassword(
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
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Login',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text('学習履歴・お気に入りをクラウドに保存します。', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 24),
                if (user != null) Card(
                    child: ListTile(
                      leading: const Icon(Icons.verified_user_outlined),
                      title: Text(user.email ?? 'Guest user'),
                      subtitle: Text(user.uid),
                    ),
                  ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _loading ? null : _signInWithEmail,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in / ログイン'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _loading ? null : _createAccount,
                  child: const Text('Create account / 新規登録'),
                ),
                TextButton(
                  onPressed: _loading ? null : _signInAnonymously,
                  child: const Text('Continue as guest / ゲストで開始'),
                ),
                if (_loading) const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_message != null) Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_message!, textAlign: TextAlign.center),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
