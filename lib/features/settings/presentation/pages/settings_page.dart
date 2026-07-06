import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _furigana = true;
  bool _darkMode = false;
  double _dailyGoal = 30;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                Text('Settings（設定）', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Account（アカウント）',
                  subtitle: 'Manage profile and login（プロフィールとログイン）',
                ),
                _SettingsTile(
                  icon: Icons.star_outline_rounded,
                  title: 'Favorite（お気に入り）',
                  subtitle: 'Review saved words（保存した単語を復習）',
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Text('Study Goal（学習目標）: ${_dailyGoal.round()} min', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                          ],
                        ),
                        Slider(
                          value: _dailyGoal,
                          min: 10,
                          max: 120,
                          divisions: 11,
                          label: '${_dailyGoal.round()} min',
                          onChanged: (value) => setState(() => _dailyGoal = value),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: SwitchListTile(
                    value: _furigana,
                    onChanged: (value) => setState(() => _furigana = value),
                    title: const Text('Show furigana（ふりがな表示）'),
                    subtitle: const Text('単語と例文で読み仮名を表示します。'),
                    secondary: Icon(Icons.text_fields_rounded, color: theme.colorScheme.primary),
                  ),
                ),
                Card(
                  child: SwitchListTile(
                    value: _darkMode,
                    onChanged: (value) => setState(() => _darkMode = value),
                    title: const Text('Dark Mode（ダークモード）'),
                    subtitle: const Text('落ち着いた暗色テーマに切り替えます。'),
                    secondary: Icon(Icons.dark_mode_outlined, color: theme.colorScheme.primary),
                  ),
                ),
                const _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About this app（このアプリについて）',
                  subtitle: 'JLPT Master 1.0.0 / © 2026',
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(icon, color: theme.colorScheme.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}
