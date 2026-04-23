import 'package:eda_adventure/models/food_models.dart';
import 'package:eda_adventure/screens/recipe_screen.dart';
import 'package:eda_adventure/state/app_state.dart';
import 'package:eda_adventure/widgets/gradient_background.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
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
        final selections = countries
            .expand(
              (country) => country.dishes.expand(
                (dish) => dish.recipesByDifficulty.values.map(
                  (recipe) => FavoriteSelection(
                    country: country,
                    dish: dish,
                    recipe: recipe,
                  ),
                ),
              ),
            )
            .where((selection) => appState.favoriteRecipeIds.contains(selection.recipe.id))
            .toList();
        final grouped = <CountryCuisine, List<FavoriteSelection>>{};
        for (final selection in selections) {
          grouped.putIfAbsent(selection.country, () => <FavoriteSelection>[]).add(selection);
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Избранное')),
          body: GradientBackground(
            child: selections.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Пока пусто. Сохрани пару рецептов.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: grouped.entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final group = grouped.entries.elementAt(index);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${group.key.flag} ${group.key.nameRu}',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              ...group.value.map(
                                (selection) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => RecipeScreen(
                                            country: selection.country,
                                            dish: selection.dish,
                                            recipe: selection.recipe,
                                            appState: appState,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.72),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            selection.dish.imageEmoji,
                                            style: const TextStyle(fontSize: 30),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  selection.dish.nameRu,
                                                  style: theme.textTheme.titleMedium,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${selection.recipe.difficulty.label} · ${selection.recipe.cookingTime}',
                                                  style: theme.textTheme.bodyMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right_rounded),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
