import 'package:eda_adventure/models/food_models.dart';
import 'package:eda_adventure/screens/favorites_screen.dart';
import 'package:eda_adventure/screens/history_screen.dart';
import 'package:eda_adventure/screens/random_country_screen.dart';
import 'package:eda_adventure/screens/settings_screen.dart';
import 'package:eda_adventure/state/app_state.dart';
import 'package:flutter/material.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({
    super.key,
    required this.countries,
    required this.appState,
  });

  final List<CountryCuisine> countries;
  final AppState appState;

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      RandomCountryScreen(
        countries: widget.countries,
        appState: widget.appState,
      ),
      FavoritesScreen(
        countries: widget.countries,
        appState: widget.appState,
      ),
      HistoryScreen(
        countries: widget.countries,
        appState: widget.appState,
      ),
      SettingsScreen(
        appState: widget.appState,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Избранное',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history),
            label: 'История',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            selectedIcon: Icon(Icons.tune),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
