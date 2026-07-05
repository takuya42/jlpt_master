import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/feature_page_header.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _dailyReminder = true;
  bool _furigana = true;
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
              key: const PageStorageKey('settings-list'),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                const FeaturePageHeader(
                  title: 'Settings',
                  subtitle: '学習しやすい環境に調整できます。',
                  icon: Icons.settings_outlined,
                ),
                const SizedBox(height: 20),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _dailyReminder,
                        onChanged: (value) => setState(
                          () => _dailyReminder = value,
                        ),
                        title: const Text('Daily reminder'),
                        subtitle: const Text('毎日の学習リマインダーを有効にします。'),
                        secondary: const Icon(Icons.notifications_outlined),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: _furigana,
                        onChanged: (value) => setState(() => _furigana = value),
                        title: const Text('Show furigana'),
                        subtitle: const Text('漢字カードで読み仮名を表示します。'),
                        secondary: const Icon(Icons.text_fields_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily study goal: ${_dailyGoal.round()} min',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
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
                const SizedBox(height: 12),
                const AboutListTile(
                  icon: Icon(Icons.info_outline),
                  applicationName: 'JLPT Master',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2026 JLPT Master',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
