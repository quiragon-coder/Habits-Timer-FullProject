import 'package:flutter/material.dart';

import '../pages/activities_home_page.dart';
import '../pages/heatmap_overview_page.dart';

class AppScaffold extends StatefulWidget {
  final int defaultActivityIdForHeatmap;
  const AppScaffold({super.key, required this.defaultActivityIdForHeatmap});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const ActivitiesHomePage(),
      HeatmapOverviewPage(activityId: widget.defaultActivityIdForHeatmap),
      const _SettingsPlaceholder(),
    ];

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: pages[index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: 'Timers'),
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Heatmap'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Réglages'),
        ],
      ),
    );
  }
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Réglages (à venir)'));
  }
}
