import 'package:eda_adventure/models/food_models.dart';
import 'package:eda_adventure/screens/recipe_screen.dart';
import 'package:eda_adventure/state/app_state.dart';
import 'package:eda_adventure/widgets/app_page_route.dart';
import 'package:eda_adventure/widgets/gradient_background.dart';
import 'package:flutter/material.dart';

class RecipeBrowserScreen extends StatefulWidget {
  const RecipeBrowserScreen({
    super.key,
    required this.selections,
    required this.appState,
    this.quickMode = false,
    this.titleOverride,
    this.subtitleOverride,
  });

  final List<RecipeSelection> selections;
  final AppState appState;
  final bool quickMode;
  final String? titleOverride;
  final String? subtitleOverride;

  @override
  State<RecipeBrowserScreen> createState() => _RecipeBrowserScreenState();
}

class _RecipeBrowserScreenState extends State<RecipeBrowserScreen> {
  late RecipeFilters _filters;

  static const _types = <String, String>{
    'all': 'Все',
    'soup': 'Супы',
    'street': 'Стритфуд',
    'rice': 'Рис',
    'pasta': 'Паста',
    'stew': 'Рагу',
    'curry': 'Карри',
    'bake': 'Запеканки',
    'vegetable': 'Овощное',
    'grain': 'Крупы',
    'noodles': 'Лапша',
  };

  static const _tagOptions = <String>[
    'мясо',
    'птица',
    'рыба',
    'вегетарианское',
    'острое',
    'быстрое',
    'бюджетное',
  ];

  @override
  void initState() {
    super.initState();
    _filters = RecipeFilters(
      quickOnly: widget.quickMode,
      maxMinutes: widget.quickMode ? 30 : null,
      smallPortionsOnly: widget.quickMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = widget.selections.where(_filters.matches).toList()
      ..sort((a, b) => a.recipe.minutes.compareTo(b.recipe.minutes));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titleOverride ?? (widget.quickMode ? 'Быстрый режим' : 'Подбор рецептов'),
        ),
      ),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(
              widget.subtitleOverride ??
                  (widget.quickMode
                      ? 'Быстро, просто, без страны'
                      : 'Фильтры по времени, типу и вкусу'),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск по блюду, стране или ингредиенту',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _filters = _filters.copyWith(query: value);
                });
              },
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [30, 60, 120].map((minutes) {
                final selected = _filters.maxMinutes == minutes;
                return ChoiceChip(
                  label: Text('до $minutes мин'),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _filters = _filters.copyWith(
                        maxMinutes: selected ? null : minutes,
                        clearMaxMinutes: selected,
                      );
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _types.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final entry = _types.entries.elementAt(index);
                  return ChoiceChip(
                    label: Text(entry.value),
                    selected: _filters.type == entry.key,
                    onSelected: (_) {
                      setState(() {
                        _filters = _filters.copyWith(type: entry.key);
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                (label: 'Любая острота', level: null),
                (label: 'Мягкое', level: 0),
                (label: 'Умеренно', level: 1),
                (label: 'Острое', level: 2),
              ].map((item) {
                final selected = _filters.maxSpiceLevel == item.level ||
                    (_filters.maxSpiceLevel == null && item.level == null);
                return ChoiceChip(
                  label: Text(item.label),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _filters = _filters.copyWith(
                        maxSpiceLevel: item.level,
                        clearMaxSpiceLevel: item.level == null,
                      );
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tagOptions.map((tag) {
                final selected = _filters.requiredTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (_) {
                    final next = {..._filters.requiredTags};
                    if (selected) {
                      next.remove(tag);
                    } else {
                      next.add(tag);
                    }
                    setState(() {
                      _filters = _filters.copyWith(requiredTags: next);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Не острое'),
                  selected: !_filters.allowSpicy,
                  onSelected: (_) {
                    setState(() {
                      _filters = _filters.copyWith(allowSpicy: !_filters.allowSpicy);
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Не экзотика'),
                  selected: !_filters.allowExotic,
                  onSelected: (_) {
                    setState(() {
                      _filters = _filters.copyWith(allowExotic: !_filters.allowExotic);
                    });
                  },
                ),
                FilterChip(
                  label: const Text('1-2 порции'),
                  selected: _filters.smallPortionsOnly,
                  onSelected: (_) {
                    setState(() {
                      _filters = _filters.copyWith(
                        smallPortionsOnly: !_filters.smallPortionsOnly,
                      );
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Найдено: ${filtered.length}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'Ничего не найдено.\nПопробуй убрать часть фильтров.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              )
            else
              ...filtered.map(
                (selection) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      title: Text('${selection.dish.imageEmoji} ${selection.dish.nameRu}'),
                      subtitle: Text(
                        '${selection.country.flag} ${selection.country.nameRu} · ${selection.recipe.difficulty.label} · ${selection.recipe.cookingTime}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).push(
                          AppPageRoute<void>(
                            builder: (_) => RecipeScreen(
                              country: selection.country,
                              dish: selection.dish,
                              recipe: selection.recipe,
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
