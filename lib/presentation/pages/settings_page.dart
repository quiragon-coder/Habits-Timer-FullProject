import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _kPref24h = 'pref_24h';
  static const _kPrefHaptics = 'pref_haptics';

  bool _use24h = true;
  bool _haptics = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _use24h = sp.getBool(_kPref24h) ?? true;
      _haptics = sp.getBool(_kPrefHaptics) ?? true;
      _loading = false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Affichage', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Format 24 heures'),
                  subtitle:
                  const Text('Applique 24h dans les affichages temporels'),
                  value: _use24h,
                  onChanged: (v) {
                    setState(() => _use24h = v);
                    _save(_kPref24h, v);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Format ${v ? "24h" : "AM/PM"} enregistré')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Interactions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Retour haptique'),
                  subtitle:
                  const Text('Vibration légère lors des actions clés'),
                  value: _haptics,
                  onChanged: (v) {
                    setState(() => _haptics = v);
                    _save(_kPrefHaptics, v);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Haptique ${v ? "activé" : "désactivé"}')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('Habits Timer — v0.1',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
