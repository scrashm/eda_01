import 'package:eda_adventure/models/food_models.dart';
import 'package:eda_adventure/screens/app_shell_screen.dart';
import 'package:eda_adventure/screens/onboarding_screen.dart';
import 'package:eda_adventure/state/app_state.dart';
import 'package:eda_adventure/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EdaAdventureApp extends StatelessWidget {
  const EdaAdventureApp({
    super.key,
    required this.appState,
    required this.countries,
  });

  final AppState appState;
  final List<CountryCuisine> countries;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Еда-приключение',
      theme: buildAppTheme(),
      home: appState.onboardingSeen
          ? AppShellScreen(
              countries: countries,
              appState: appState,
            )
          : OnboardingScreen(
              onStart: () async {
                await appState.markOnboardingSeen();
              },
              child: AppShellScreen(
                countries: countries,
                appState: appState,
              ),
            ),
    );
  }
}
