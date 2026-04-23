import 'package:eda_adventure/state/app_state.dart';
import 'package:eda_adventure/widgets/gradient_background.dart';
import 'package:flutter/material.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({
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
        final items = appState.shoppingList;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Список покупок'),
            actions: [
              if (items.isNotEmpty)
                TextButton(
                  onPressed: appState.clearShoppingList,
                  child: const Text('Очистить'),
                ),
            ],
          ),
          body: GradientBackground(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'Список покупок пуст.',
                      style: theme.textTheme.titleMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          title: Text(item.displayName),
                          subtitle: Text(
                            item.variants.length > 1
                                ? '${item.count} совпадения · ${item.variants.join(' / ')}'
                                : item.variants.first,
                          ),
                          trailing: IconButton(
                            onPressed: () => appState.removeShoppingItem(item.key),
                            icon: const Icon(Icons.close_rounded),
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
