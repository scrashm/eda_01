import 'package:eda_adventure/models/food_models.dart';
import 'package:flutter/material.dart';

class CountryResultCard extends StatelessWidget {
  const CountryResultCard({
    super.key,
    required this.country,
    required this.onReroll,
    required this.onOpenMenu,
    required this.onRandomRecipe,
  });

  final CountryCuisine country;
  final VoidCallback onReroll;
  final VoidCallback onOpenMenu;
  final VoidCallback onRandomRecipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(country.flag, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(country.nameRu, style: theme.textTheme.titleLarge),
                      Text(country.nameOriginal, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(country.fact, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 14),
            Text(
              country.dishes.map((dish) => dish.nameRu).join(' • '),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReroll,
                    child: const Text('Реролл'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onOpenMenu,
                    child: const Text('Открыть меню'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: onRandomRecipe,
                child: const Text('Случайное блюдо'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
