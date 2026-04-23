import 'package:eda_adventure/models/food_models.dart';
import 'package:eda_adventure/state/app_state.dart';
import 'package:eda_adventure/widgets/gradient_background.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.countries,
    required this.appState,
  });

  final List<CountryCuisine> countries;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final items = appState.historyIds
            .map((id) => countries.firstWhereOrNull((country) => country.id == id))
            .whereType<CountryCuisine>()
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('История'),
            actions: [
              if (items.isNotEmpty)
                TextButton(
                  onPressed: appState.clearHistory,
                  child: const Text('Очистить'),
                ),
            ],
          ),
          body: GradientBackground(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'История пока пустая.',
                      style: theme.textTheme.titleMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final country = items[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          title: Text('${country.flag} ${country.nameRu}'),
                          subtitle: Text(country.fact),
                          trailing: IconButton(
                            onPressed: () => appState.removeHistoryAt(index),
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Удалить',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
