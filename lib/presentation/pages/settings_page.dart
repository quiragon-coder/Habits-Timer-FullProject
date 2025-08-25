import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  static const route = '/settings';
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final ctrl = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Apparence', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          RadioListTile<ThemeMode>(
            title: const Text('Système'),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (m) => ctrl.setThemeMode(m ?? ThemeMode.system),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Clair'),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (m) => ctrl.setThemeMode(m ?? ThemeMode.light),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Sombre'),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (m) => ctrl.setThemeMode(m ?? ThemeMode.dark),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Retour haptique'),
            value: settings.hapticsEnabled,
            onChanged: (v) => ctrl.setHaptics(v),
            subtitle: const Text('Vibrations sur Play / Pause / Stop'),
          ),
        ],
      ),
    );
  }
}
