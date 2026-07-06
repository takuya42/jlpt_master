import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                Text('設定', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                Card(
                  child: Column(children: [
                    const ListTile(leading: Icon(Icons.person_outline), title: Text('アカウント'), trailing: Icon(Icons.chevron_right_rounded)),
                    const ListTile(leading: Icon(Icons.favorite_border), title: Text('お気に入り'), trailing: Icon(Icons.chevron_right_rounded)),
                    const ListTile(leading: Icon(Icons.flag_outlined), title: Text('学習目標'), trailing: Icon(Icons.chevron_right_rounded)),
                    SwitchListTile(
                      value: _darkMode,
                      onChanged: (value) => setState(() => _darkMode = value),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('ダークモード'),
                    ),
                    const AboutListTile(
                      icon: Icon(Icons.info_outline),
                      applicationName: 'JLPT Master',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 JLPT Master',
                      child: Text('このアプリについて'),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
