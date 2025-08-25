import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  static const route = '/settings';
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Thème', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_suggest), label: Text('Système')),
              ButtonSegment(value: ThemeMode.light,  icon: Icon(Icons.light_mode),       label: Text('Clair')),
              ButtonSegment(value: ThemeMode.dark,   icon: Icon(Icons.dark_mode),        label: Text('Sombre')),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) {
              if (s.isNotEmpty) {
                controller.setThemeMode(s.first);
              }
            },
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Retour haptique'),
            value: settings.hapticsEnabled,
            onChanged: (v) => controller.setHaptics(v),
          ),
        ],
      ),
    );
  }
}
