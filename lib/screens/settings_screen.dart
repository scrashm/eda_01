import 'package:eda_adventure/state/app_state.dart';
import 'package:eda_adventure/widgets/gradient_background.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Настройки')),
          body: GradientBackground(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Card(
                  child: SwitchListTile(
                    value: appState.compactMode,
                    onChanged: appState.setCompactMode,
                    title: const Text('Компактный режим'),
                    subtitle: const Text('Меньше отступов и плотнее карточки'),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: const Text('Первый экран'),
                    subtitle: Text(
                      appState.onboardingSeen
                          ? 'Онбординг уже скрыт после первого запуска'
                          : 'Онбординг ещё будет показан',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
