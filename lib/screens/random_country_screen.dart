import 'dart:math';

import 'package:eda_adventure/data/recipe_index.dart';
import 'package:eda_adventure/models/food_models.dart';
import 'package:eda_adventure/screens/country_menu_screen.dart';
import 'package:eda_adventure/screens/favorites_screen.dart';
import 'package:eda_adventure/screens/history_screen.dart';
import 'package:eda_adventure/screens/pantry_screen.dart';
import 'package:eda_adventure/screens/recipe_browser_screen.dart';
import 'package:eda_adventure/screens/recipe_screen.dart';
import 'package:eda_adventure/screens/shopping_list_screen.dart';
import 'package:eda_adventure/state/app_state.dart';
import 'package:eda_adventure/theme/app_theme.dart';
import 'package:eda_adventure/theme/responsive.dart';
import 'package:eda_adventure/widgets/app_page_route.dart';
import 'package:eda_adventure/widgets/country_result_card.dart';
import 'package:eda_adventure/widgets/empty_result_card.dart';
import 'package:eda_adventure/widgets/gradient_background.dart';
import 'package:eda_adventure/widgets/section_header.dart';
import 'package:flutter/material.dart';

class RandomCountryScreen extends StatefulWidget {
  const RandomCountryScreen({
    super.key,
    required this.countries,
    required this.appState,
  });

  final List<CountryCuisine> countries;
  final AppState appState;

  @override
  State<RandomCountryScreen> createState() => _RandomCountryScreenState();
}

class _RandomCountryScreenState extends State<RandomCountryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  final Random _random = Random();
  CountryCuisine? _selectedCountry;
  bool _isRolling = false;
  String _selectedContinent = 'Все';

  List<RecipeSelection> get _allSelections => buildRecipeSelections(widget.countries);
  List<String> get _allKeywords => collectPantryKeywords(widget.countries);

  List<String> get _continents => [
        'Все',
        ...{for (final country in widget.countries) country.continent},
      ];

  List<CountryCuisine> get _filteredCountries {
    if (_selectedContinent == 'Все') {
      return widget.countries;
    }
    return widget.countries
        .where((country) => country.continent == _selectedContinent)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _rollCountry() async {
    if (_isRolling || _filteredCountries.isEmpty) {
      return;
    }

    setState(() {
      _isRolling = true;
    });

    await _spinController.forward(from: 0);
    final country = _filteredCountries[_random.nextInt(_filteredCountries.length)];
    await widget.appState.addHistory(country.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedCountry = country;
      _isRolling = false;
    });
  }

  Future<void> _openFavorites() async {
    await Navigator.of(context).push(
      AppPageRoute<void>(
        builder: (_) => FavoritesScreen(
          countries: widget.countries,
          appState: widget.appState,
        ),
      ),
    );
  }

  void _openRandomRecipe() {
    if (_filteredCountries.isEmpty) {
      return;
    }

    final country = _filteredCountries[_random.nextInt(_filteredCountries.length)];
    final selection = country.randomSelection(_random);
    widget.appState.addHistory(country.id);

    Navigator.of(context).push(
      AppPageRoute<void>(
        builder: (_) => RecipeScreen(
          country: country,
          dish: selection.dish,
          recipe: selection.recipe,
          appState: widget.appState,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = isCompactLayout(context, widget.appState);
    final lastSelection = findRecipeSelectionById(
      widget.countries,
      widget.appState.lastRecipeId,
    );

    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final historyCountries = widget.appState.historyIds
            .map((id) => widget.countries.firstWhereOrNull((country) => country.id == id))
            .whereType<CountryCuisine>()
            .take(5)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Крутим глобус'),
            actions: [
              IconButton(
                onPressed: _openFavorites,
                tooltip: 'Избранное',
                icon: Badge.count(
                  count: widget.appState.favoriteRecipeIds.length,
                  isLabelVisible: widget.appState.favoriteRecipeIds.isNotEmpty,
                  child: const Icon(Icons.bookmark_border_rounded),
                ),
              ),
            ],
          ),
          body: GradientBackground(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                const SectionHeader(
                  eyebrow: 'Выбор',
                  title: 'Страна дня',
                  subtitle: 'Нажми на круг и смотри, что выпадет.',
                ),
                const SizedBox(height: 16),
                if (lastSelection != null) ...[
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      leading: Text(lastSelection.dish.imageEmoji, style: const TextStyle(fontSize: 28)),
                      title: const Text('Последний рецепт'),
                      subtitle: Text(
                        '${lastSelection.dish.nameRu} · ${lastSelection.recipe.cookingTime}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).push(
                          AppPageRoute<void>(
                            builder: (_) => RecipeScreen(
                              country: lastSelection.country,
                              dish: lastSelection.dish,
                              recipe: lastSelection.recipe,
                              appState: widget.appState,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  height: compact ? 92 : 106,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _ShortcutCard(
                        icon: '⚡',
                        title: 'Быстрый режим',
                        subtitle: 'до 30 минут',
                        onTap: () {
                          Navigator.of(context).push(
                            AppPageRoute<void>(
                              builder: (_) => RecipeBrowserScreen(
                                selections: _allSelections,
                                appState: widget.appState,
                                quickMode: true,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _ShortcutCard(
                        icon: '🥕',
                        title: 'Из того, что есть',
                        subtitle: 'по ингредиентам',
                        onTap: () {
                          Navigator.of(context).push(
                            AppPageRoute<void>(
                              builder: (_) => PantryScreen(
                                selections: _allSelections,
                                keywords: _allKeywords,
                                appState: widget.appState,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _ShortcutCard(
                        icon: '🧭',
                        title: 'Подбор рецептов',
                        subtitle: 'с фильтрами',
                        onTap: () {
                          Navigator.of(context).push(
                            AppPageRoute<void>(
                              builder: (_) => RecipeBrowserScreen(
                                selections: _allSelections,
                                appState: widget.appState,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _ShortcutCard(
                        icon: '🕘',
                        title: 'История',
                        subtitle: 'все выпадения',
                        onTap: () {
                          Navigator.of(context).push(
                            AppPageRoute<void>(
                              builder: (_) => HistoryScreen(
                                countries: widget.countries,
                                appState: widget.appState,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _ShortcutCard(
                        icon: '🛒',
                        title: 'Покупки',
                        subtitle: 'список ингредиентов',
                        onTap: () {
                          Navigator.of(context).push(
                            AppPageRoute<void>(
                              builder: (_) => ShoppingListScreen(
                                appState: widget.appState,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Подборки', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                SizedBox(
                  height: compact ? 92 : 106,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _ShortcutCard(
                        icon: '🍽️',
                        title: 'Ужин на двоих',
                        subtitle: 'уютно и быстро',
                        onTap: () {
                          Navigator.of(context).push(
                            AppPageRoute<void>(
                              builder: (_) => RecipeBrowserScreen(
                                selections: buildCuratedCollection(
                                  _allSelections,
                                  'dinner_for_two',
                                ),
                                appState: widget.appState,
                                titleOverride: 'Ужин на двоих',
                                subtitleOverride: 'Небольшие порции и разумное время',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _ShortcutCard(
                        icon: '🥂',
                        title: 'Гости пришли',
                        subtitle: 'на несколько порций',
                        onTap: () {
                          Navigator.of(context).push(
                            AppPageRoute<void>(
                              builder: (_) => RecipeBrowserScreen(
                                selections: buildCuratedCollection(
                                  _allSelections,
                                  'guests_arrived',
                                ),
                                appState: widget.appState,
                                titleOverride: 'Гости пришли внезапно',
                                subtitleOverride: 'Сытнее и на компанию',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _ShortcutCard(
                        icon: '🧪',
                        title: 'Выходной эксперимент',
                        subtitle: 'пора заморочиться',
                        onTap: () {
                          Navigator.of(context).push(
                            AppPageRoute<void>(
                              builder: (_) => RecipeBrowserScreen(
                                selections: buildCuratedCollection(
                                  _allSelections,
                                  'weekend_experiment',
                                ),
                                appState: widget.appState,
                                titleOverride: 'Эксперимент на выходные',
                                subtitleOverride: 'Дольше, сложнее, интереснее',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _continents.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final continent = _continents[index];
                      return ChoiceChip(
                        label: Text(continent),
                        selected: _selectedContinent == continent,
                        onSelected: (_) {
                          setState(() {
                            _selectedContinent = continent;
                            _selectedCountry = null;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.fromLTRB(18, compact ? 18 : 24, 18, compact ? 18 : 22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF3F7F4),
                        Color(0xFFF9F4EC),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutBack,
                        width: _isRolling ? (compact ? 250 : 286) : (compact ? 236 : 268),
                        height: _isRolling ? (compact ? 250 : 286) : (compact ? 236 : 268),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFFEFF6F2),
                              Color(0xFFDCEAE5),
                              Color(0xFFCADFD6),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFBFD4CC),
                            width: 2,
                          ),
                          boxShadow: [
                            const BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 26,
                              offset: Offset(0, 18),
                            ),
                            BoxShadow(
                              color: const Color(0x552F6159),
                              blurRadius: _isRolling ? 42 : 28,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: RotationTransition(
                          turns: Tween<double>(begin: 0, end: 2.8).animate(
                            CurvedAnimation(
                              parent: _spinController,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: _rollCountry,
                              child: Center(
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 220),
                                  scale: _isRolling ? 1.08 : 1,
                                  child: Text(
                                    _isRolling ? '🍽️' : '🌍',
                                    style: TextStyle(fontSize: compact ? 92 : 108),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 16 : 22),
                      Text(
                        _isRolling ? 'Ищем...' : 'Жми на круг',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Страна, блюда и сложность выберутся сами.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: compact ? 14 : 18),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _rollCountry,
                              icon: const Icon(Icons.casino_outlined),
                              label: const Text('Выбрать'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _openRandomRecipe,
                        icon: const Icon(Icons.shuffle_rounded),
                        label: const Text('Случайное блюдо'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _selectedCountry == null
                      ? const EmptyResultCard(key: ValueKey('empty'))
                      : CountryResultCard(
                          key: ValueKey(_selectedCountry!.id),
                          country: _selectedCountry!,
                          onReroll: _rollCountry,
                          onOpenMenu: () {
                            Navigator.of(context).push(
                              AppPageRoute<void>(
                                builder: (_) => CountryMenuScreen(
                                  country: _selectedCountry!,
                                  appState: widget.appState,
                                ),
                              ),
                            );
                          },
                          onRandomRecipe: () {
                            final selection = _selectedCountry!.randomSelection(_random);
                            Navigator.of(context).push(
                              AppPageRoute<void>(
                                builder: (_) => RecipeScreen(
                                  country: _selectedCountry!,
                                  dish: selection.dish,
                                  recipe: selection.recipe,
                                  appState: widget.appState,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (historyCountries.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Последние страны', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 58,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: historyCountries.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final country = historyCountries[index];
                        return ActionChip(
                          avatar: Text(country.flag),
                          label: Text(country.nameRu),
                          onPressed: () {
                            setState(() {
                              _selectedCountry = country;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 162,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTightHeight = constraints.maxHeight < 90;
          final isVeryTightHeight = constraints.maxHeight < 64;
          final useHorizontalLayout = constraints.maxHeight < 110;
          return Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isVeryTightHeight ? 10 : (isTightHeight ? 12 : 16),
                  vertical: isVeryTightHeight ? 4 : (isTightHeight ? 8 : 16),
                ),
                child: useHorizontalLayout
                    ? Row(
                        children: [
                          Text(
                            icon,
                            style: TextStyle(fontSize: isVeryTightHeight ? 16 : 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: isVeryTightHeight
                                      ? theme.textTheme.labelMedium
                                      : theme.textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (!isVeryTightHeight) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
