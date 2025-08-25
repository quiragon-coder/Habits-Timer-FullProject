import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Apparence', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Thème sombre (bientôt)'),
                  subtitle: const Text('Suivre le système pour le moment'),
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: null, // sera branché plus tard
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Format 24 heures'),
                  subtitle: const Text('Utiliser 24h dans les affichages'),
                  value: true,
                  onChanged: (v) {
                    // TODO: persister la préférence et rafraîchir l’UI
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Préférence 24h à venir')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Général', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: const Text('Langue'),
                  subtitle: const Text('Français (bientôt multilingue)'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sélecteur de langue à venir')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Export / Sauvegarde'),
                  subtitle: const Text('CSV / JSON (à venir)'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export à venir')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Habits Timer — v0.1',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
