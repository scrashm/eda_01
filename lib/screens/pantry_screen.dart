import 'package:eda_adventure/models/food_models.dart';
import 'package:eda_adventure/screens/recipe_screen.dart';
import 'package:eda_adventure/state/app_state.dart';
import 'package:eda_adventure/widgets/gradient_background.dart';
import 'package:flutter/material.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({
    super.key,
    required this.selections,
    required this.keywords,
    required this.appState,
  });

  final List<RecipeSelection> selections;
  final List<String> keywords;
  final AppState appState;

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final Set<String> _selectedKeywords = <String>{};
  bool _allowSpicy = true;
  bool _allowExotic = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final results = widget.selections
        .where((selection) {
          if (!_allowSpicy && selection.dish.spiceLevel >= 2) {
            return false;
          }
          if (!_allowExotic && selection.dish.exoticLevel >= 2) {
            return false;
          }
          if (_selectedKeywords.isEmpty) {
            return true;
          }
          return _selectedKeywords.any(selection.dish.pantryKeywords.contains);
        })
        .map(
          (selection) => (
            selection: selection,
            score: _selectedKeywords.where(selection.dish.pantryKeywords.contains).length,
          ),
        )
        .where((item) => _selectedKeywords.isEmpty || item.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Из того, что есть'),
      ),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text('Выбери ингредиенты', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Подберём блюда по совпадениям.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.keywords.map((keyword) {
                final selected = _selectedKeywords.contains(keyword);
                return FilterChip(
                  label: Text(keyword),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _selectedKeywords.remove(keyword);
                      } else {
                        _selectedKeywords.add(keyword);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Не острое'),
                  selected: !_allowSpicy,
                  onSelected: (_) {
                    setState(() {
                      _allowSpicy = !_allowSpicy;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Не экзотика'),
                  selected: !_allowExotic,
                  onSelected: (_) {
                    setState(() {
                      _allowExotic = !_allowExotic;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Найдено: ${results.length}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'Пока нет совпадений.',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              )
            else
              ...results.take(20).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      title: Text('${item.selection.dish.imageEmoji} ${item.selection.dish.nameRu}'),
                      subtitle: Text(
                        '${item.selection.country.flag} ${item.selection.country.nameRu} · совпадений: ${item.score} · ${item.selection.recipe.cookingTime}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => RecipeScreen(
                              country: item.selection.country,
                              dish: item.selection.dish,
                              recipe: item.selection.recipe,
                              appState: widget.appState,
                            ),
                          ),
                        );
                      },
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
