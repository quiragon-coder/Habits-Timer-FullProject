import 'package:flutter/material.dart';
import 'activities_home_page.dart';
import 'heatmap_overview_page.dart';
import 'settings_page.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ActivitiesHomePage(),
    HeatmapOverviewPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            label: 'Timers',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_on_outlined),
            label: 'Heatmap',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Réglages',
          ),
        ],
      ),
    );
  }
}
