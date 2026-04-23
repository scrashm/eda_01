import 'package:eda_adventure/models/food_models.dart';
import 'package:eda_adventure/screens/recipe_screen.dart';
import 'package:eda_adventure/state/app_state.dart';
import 'package:eda_adventure/theme/responsive.dart';
import 'package:eda_adventure/widgets/app_page_route.dart';
import 'package:eda_adventure/widgets/dish_image_card.dart';
import 'package:eda_adventure/widgets/gradient_background.dart';
import 'package:eda_adventure/widgets/section_header.dart';
import 'package:flutter/material.dart';

class CountryMenuScreen extends StatelessWidget {
  const CountryMenuScreen({
    super.key,
    required this.country,
    required this.appState,
  });

  final CountryCuisine country;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = isCompactLayout(context, appState);

    return Scaffold(
      appBar: AppBar(
        title: Text('${country.flag} ${country.nameRu}'),
      ),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            SectionHeader(
              eyebrow: 'Меню',
              title: '${country.dishes.length} блюда',
              subtitle: country.fact,
            ),
            const SizedBox(height: 18),
            ...country.dishes.map(
              (dish) => Padding(
                padding: EdgeInsets.only(bottom: compact ? 10 : 14),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 14 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DishImageCard(
                          imageUrl: dish.imageUrl,
                          heroTag: '${dish.id}-image',
                          aspectRatio: compact ? 4 / 5 : 3 / 4,
                          borderRadius: 22,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(dish.imageEmoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dish.nameRu, style: theme.textTheme.titleLarge),
                                  const SizedBox(height: 4),
                                  Text(dish.nameOriginal, style: theme.textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(dish.blurb, style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: Difficulty.values.map((difficulty) {
                            final recipe = dish.recipesByDifficulty[difficulty]!;
                            return OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  AppPageRoute<void>(
                                    builder: (_) => RecipeScreen(
                                      country: country,
                                      dish: dish,
                                      recipe: recipe,
                                      appState: appState,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                '${difficulty.emoji} ${difficulty.label} · ${recipe.cookingTime}',
                              ),
                            );
                          }).toList(),
                        ),
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
  }
}
