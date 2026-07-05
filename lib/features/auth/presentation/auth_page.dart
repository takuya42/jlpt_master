import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../app/firebase/firebase_services.dart';

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

  Future<void> _run(Future<void> Function() action, String successMessage) async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await action();
      await FirebaseServices.registerMessagingToken();
      await FirebaseServices.uploadProfileBackup();
      await FirebaseServices.logScreenView('account');
      if (mounted) setState(() => _message = successMessage);
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _message = error.message ?? error.code);
    } on FirebaseException catch (error) {
      if (mounted) setState(() => _message = error.message ?? error.code);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithEmail() => _run(
        () => FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
        'Signed in successfully / ログインしました',
      );

  Future<void> _createAccount() => _run(
        () => FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
        'Account created / アカウントを作成しました',
      );

  Future<void> _resetPassword() => _run(
        () => FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        ),
        'Password reset email sent / 再設定メールを送信しました',
      );

  Future<void> _signOut() => _run(
        FirebaseAuth.instance.signOut,
        'Signed out / ログアウトしました',
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Account',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '学習履歴・お気に入り・進捗をクラウドに同期します。',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (user != null)
                      _SignedInCard(user: user, onSignOut: _loading ? null : _signOut)
                    else
                      _SignedOutForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        loading: _loading,
                        onSignIn: _signInWithEmail,
                        onCreateAccount: _createAccount,
                        onResetPassword: _resetPassword,
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
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SignedInCard extends StatelessWidget {
  const _SignedInCard({required this.user, required this.onSignOut});

  final User user;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.verified_user_outlined)),
              title: Text(user.email ?? 'Signed-in learner'),
              subtitle: Text(user.uid),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout),
              label: const Text('Logout / ログアウト'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedOutForm extends StatelessWidget {
  const _SignedOutForm({
    required this.emailController,
    required this.passwordController,
    required this.loading,
    required this.onSignIn,
    required this.onCreateAccount,
    required this.onResetPassword,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool loading;
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        children: [
          TextField(
            controller: emailController,
            autofillHints: const [AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            autofillHints: const [AutofillHints.password],
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: loading ? null : onSignIn,
            icon: const Icon(Icons.login),
            label: const Text('Sign in / ログイン'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: loading ? null : onCreateAccount,
            child: const Text('Create account / 新規登録'),
          ),
          TextButton(
            onPressed: loading ? null : onResetPassword,
            child: const Text('Reset password / パスワード再設定'),
          ),
        ],
      ),
    );
  }
}
