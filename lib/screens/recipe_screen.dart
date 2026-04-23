import 'package:eda_adventure/models/food_models.dart';
import 'package:eda_adventure/state/app_state.dart';
import 'package:eda_adventure/theme/app_theme.dart';
import 'package:eda_adventure/widgets/content_block.dart';
import 'package:eda_adventure/widgets/dish_image_card.dart';
import 'package:eda_adventure/widgets/gradient_background.dart';
import 'package:eda_adventure/widgets/meta_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({
    super.key,
    required this.country,
    required this.dish,
    required this.recipe,
    required this.appState,
  });

  final CountryCuisine country;
  final Dish dish;
  final Recipe recipe;
  final AppState appState;

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appState.setLastRecipe(widget.recipe.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final favorite = widget.appState.favoriteRecipeIds.contains(widget.recipe.id);

        return Scaffold(
          appBar: AppBar(
            title: Text('${widget.country.flag} ${widget.country.nameRu}'),
            actions: [
              IconButton(
                onPressed: () => widget.appState.toggleFavorite(widget.recipe.id),
                tooltip: favorite ? 'Убрать из избранного' : 'Сохранить',
                icon: Icon(
                  favorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                ),
              ),
              IconButton(
                onPressed: () {
                  final shareText = [
                    '${widget.country.flag} ${widget.country.nameRu}',
                    '${widget.dish.nameRu} (${widget.dish.nameOriginal})',
                    'Сложность: ${widget.recipe.difficulty.label}',
                    'Время: ${widget.recipe.cookingTime}',
                    '',
                    'Ингредиенты:',
                    ...widget.recipe.ingredients.map((item) => '• $item'),
                    '',
                    'Шаги:',
                    ...widget.recipe.steps.asMap().entries.map(
                          (entry) => '${entry.key + 1}. ${entry.value}',
                        ),
                  ].join('\n');

                  Clipboard.setData(ClipboardData(text: shareText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Рецепт скопирован')),
                  );
                },
                tooltip: 'Поделиться',
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
          body: GradientBackground(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DishImageCard(
                        imageUrl: widget.dish.imageUrl,
                        heroTag: '${widget.dish.id}-image',
                        aspectRatio: 4 / 5,
                        borderRadius: 24,
                      ),
                      const SizedBox(height: 16),
                      Text(widget.dish.imageEmoji, style: const TextStyle(fontSize: 34)),
                      const SizedBox(height: 12),
                      Text(widget.dish.nameRu, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 6),
                      Text(widget.dish.nameOriginal, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      Text(widget.recipe.summary, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          MetaChip(label: '⏱ ${widget.recipe.cookingTime}'),
                          MetaChip(
                            label:
                                '${widget.recipe.difficulty.emoji} ${widget.recipe.difficulty.label}',
                          ),
                          MetaChip(label: '${widget.country.flag} ${widget.country.nameRu}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ContentBlock(
                  title: 'Ингредиенты',
                  child: Column(
                    children: widget.recipe.ingredients
                        .map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: CircleAvatar(
                                    radius: 3,
                                    backgroundColor: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(ingredient, style: theme.textTheme.bodyLarge),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                ContentBlock(
                  title: 'Как готовить',
                  child: Column(
                    children: widget.recipe.steps.asMap().entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F5F1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppColors.accentSoft,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(entry.value, style: theme.textTheme.bodyLarge),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Готовить снова'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => widget.appState.toggleFavorite(widget.recipe.id),
                  icon: Icon(
                    favorite ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined,
                  ),
                  label: Text(
                    favorite ? 'Убрать из избранного' : 'Сохранить в избранное',
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
