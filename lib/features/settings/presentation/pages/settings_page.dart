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
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              children: [
                Text('Settings\n設定', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(children: [
                      const _SettingsTile(icon: Icons.person_outline, title: 'Account', subtitle: 'アカウント'),
                      const _SettingsTile(icon: Icons.favorite_border, title: 'Favorite', subtitle: 'お気に入り'),
                      const _SettingsTile(icon: Icons.flag_outlined, title: 'Learning Goal', subtitle: '学習目標'),
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        value: _darkMode,
                        onChanged: (value) => setState(() => _darkMode = value),
                        secondary: const Icon(Icons.dark_mode_outlined),
                        title: const Text('Dark Mode', maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: const Text('ダークモード', maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      const AboutListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        icon: Icon(Icons.info_outline),
                        applicationName: 'JLPT Master',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2026 JLPT Master',
                        child: Text('About\nこのアプリについて'),
                      ),
                    ]),
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Icon(icon),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right_rounded),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}
