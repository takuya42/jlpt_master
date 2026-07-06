import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                Text('Settings（設定）', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('学習しやすい環境に調整できます。', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 20),
                Card(
                  child: SwitchListTile(
                    value: _furigana,
                    onChanged: (value) => setState(() => _furigana = value),
                    title: const Text('Show furigana（ふりがな表示）'),
                    subtitle: const Text('単語と例文で読み仮名を表示します。'),
                    secondary: const Icon(Icons.text_fields_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily study goal（1日の学習目標）: ${_dailyGoal.round()} min', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
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
