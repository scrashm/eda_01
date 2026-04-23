import 'dart:math';
import 'dart:convert';

class CountryCuisine {
  const CountryCuisine({
    required this.id,
    required this.nameRu,
    required this.nameOriginal,
    required this.flag,
    required this.continent,
    required this.fact,
    required this.dishes,
  });

  final String id;
  final String nameRu;
  final String nameOriginal;
  final String flag;
  final String continent;
  final String fact;
  final List<Dish> dishes;

  factory CountryCuisine.fromJson(Map<String, dynamic> json) {
    return CountryCuisine(
      id: json['id'] as String,
      nameRu: json['nameRu'] as String,
      nameOriginal: json['nameOriginal'] as String,
      flag: json['flag'] as String,
      continent: json['continent'] as String,
      fact: json['fact'] as String,
      dishes: (json['dishes'] as List<dynamic>)
          .map((item) => Dish.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  DishRecipeSelection randomSelection(Random random) {
    final dish = dishes[random.nextInt(dishes.length)];
    final recipe = dish.recipesByDifficulty.values.toList()[random.nextInt(3)];
    return DishRecipeSelection(dish: dish, recipe: recipe);
  }

  CountryCuisine copyWith({
    String? id,
    String? nameRu,
    String? nameOriginal,
    String? flag,
    String? continent,
    String? fact,
    List<Dish>? dishes,
  }) {
    return CountryCuisine(
      id: id ?? this.id,
      nameRu: nameRu ?? this.nameRu,
      nameOriginal: nameOriginal ?? this.nameOriginal,
      flag: flag ?? this.flag,
      continent: continent ?? this.continent,
      fact: fact ?? this.fact,
      dishes: dishes ?? this.dishes,
    );
  }
}

class Dish {
  const Dish({
    required this.id,
    required this.nameRu,
    required this.nameOriginal,
    required this.imageEmoji,
    required this.imageUrl,
    required this.blurb,
    required this.type,
    required this.tags,
    required this.spiceLevel,
    required this.exoticLevel,
    required this.pantryKeywords,
    required this.recipesByDifficulty,
  });

  final String id;
  final String nameRu;
  final String nameOriginal;
  final String imageEmoji;
  final String imageUrl;
  final String blurb;
  final String type;
  final List<String> tags;
  final int spiceLevel;
  final int exoticLevel;
  final List<String> pantryKeywords;
  final Map<Difficulty, Recipe> recipesByDifficulty;

  factory Dish.fromJson(Map<String, dynamic> json) {
    final recipes = (json['recipes'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        Difficulty.fromKey(key),
        Recipe.fromJson(value as Map<String, dynamic>),
      ),
    );

    return Dish(
      id: json['id'] as String,
      nameRu: json['nameRu'] as String,
      nameOriginal: json['nameOriginal'] as String,
      imageEmoji: json['imageEmoji'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      blurb: json['blurb'] as String,
      type: json['type'] as String? ?? 'main',
      tags: (json['tags'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
      spiceLevel: json['spiceLevel'] as int? ?? 1,
      exoticLevel: json['exoticLevel'] as int? ?? 1,
      pantryKeywords: (json['pantryKeywords'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
      recipesByDifficulty: recipes,
    );
  }

  Dish copyWith({
    String? id,
    String? nameRu,
    String? nameOriginal,
    String? imageEmoji,
    String? imageUrl,
    String? blurb,
    String? type,
    List<String>? tags,
    int? spiceLevel,
    int? exoticLevel,
    List<String>? pantryKeywords,
    Map<Difficulty, Recipe>? recipesByDifficulty,
  }) {
    return Dish(
      id: id ?? this.id,
      nameRu: nameRu ?? this.nameRu,
      nameOriginal: nameOriginal ?? this.nameOriginal,
      imageEmoji: imageEmoji ?? this.imageEmoji,
      imageUrl: imageUrl ?? this.imageUrl,
      blurb: blurb ?? this.blurb,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      exoticLevel: exoticLevel ?? this.exoticLevel,
      pantryKeywords: pantryKeywords ?? this.pantryKeywords,
      recipesByDifficulty: recipesByDifficulty ?? this.recipesByDifficulty,
    );
  }
}

class Recipe {
  const Recipe({
    required this.id,
    required this.difficulty,
    required this.cookingTime,
    required this.summary,
    required this.ingredients,
    required this.steps,
    required this.nutritionInfo,
    required this.budgetLevel,
    required this.source,
  });

  final String id;
  final Difficulty difficulty;
  final String cookingTime;
  final String summary;
  final List<String> ingredients;
  final List<String> steps;
  final NutritionInfo nutritionInfo;
  final int budgetLevel;
  final String source;

  int get minutes {
    final normalized = cookingTime.toLowerCase();
    final numbers = RegExp(r'\d+')
        .allMatches(normalized)
        .map((match) => int.parse(match.group(0)!))
        .toList();

    if (numbers.isEmpty) {
      return 0;
    }

    if (normalized.contains('час')) {
      final hours = numbers.first;
      final minutes = numbers.length > 1 ? numbers[1] : 0;
      return (hours * 60) + minutes;
    }

    return numbers.first;
  }

  int get servings {
    switch (difficulty) {
      case Difficulty.easy:
        return 2;
      case Difficulty.medium:
        return 3;
      case Difficulty.hard:
        return 4;
    }
  }

  List<Ingredient> get parsedIngredients =>
      ingredients.map(Ingredient.fromDisplay).toList(growable: false);

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      difficulty: Difficulty.fromKey(json['difficulty'] as String),
      cookingTime: json['cookingTime'] as String,
      summary: json['summary'] as String,
      ingredients: (json['ingredients'] as List<dynamic>).cast<String>(),
      steps: (json['steps'] as List<dynamic>).cast<String>(),
      nutritionInfo: NutritionInfo(
        calories: json['calories'] as int? ?? _deriveCalories(json['difficulty'] as String),
      ),
      budgetLevel: json['budgetLevel'] as int? ?? _deriveBudgetLevel(json['difficulty'] as String),
      source: json['source'] as String? ?? 'Локальная база',
    );
  }

  static int _deriveCalories(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 480;
      case 'medium':
        return 620;
      case 'hard':
        return 760;
      default:
        return 550;
    }
  }

  static int _deriveBudgetLevel(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 1;
      case 'medium':
        return 2;
      case 'hard':
        return 3;
      default:
        return 2;
    }
  }
}

class Ingredient {
  const Ingredient({
    required this.display,
    required this.name,
    required this.amount,
  });

  final String display;
  final String name;
  final String amount;

  factory Ingredient.fromDisplay(String input) {
    final parts = input.split(',');
    final name = parts.first.trim();
    final amount = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
    return Ingredient(
      display: input,
      name: name,
      amount: amount,
    );
  }
}

class Tag {
  const Tag(this.value);

  final String value;
}

class NutritionInfo {
  const NutritionInfo({
    required this.calories,
  });

  final int calories;
}

class ShoppingItem {
  const ShoppingItem({
    required this.key,
    required this.name,
    required this.displayName,
    required this.variants,
    required this.recipeIds,
    required this.count,
  });

  final String key;
  final String name;
  final String displayName;
  final List<String> variants;
  final List<String> recipeIds;
  final int count;

  ShoppingItem copyWith({
    String? key,
    String? name,
    String? displayName,
    List<String>? variants,
    List<String>? recipeIds,
    int? count,
  }) {
    return ShoppingItem(
      key: key ?? this.key,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      variants: variants ?? this.variants,
      recipeIds: recipeIds ?? this.recipeIds,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'displayName': displayName,
      'variants': variants,
      'recipeIds': recipeIds,
      'count': count,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      key: json['key'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      variants: (json['variants'] as List<dynamic>).cast<String>(),
      recipeIds: (json['recipeIds'] as List<dynamic>).cast<String>(),
      count: json['count'] as int,
    );
  }
}

class RecipeJournalEntry {
  const RecipeJournalEntry({
    required this.note,
    required this.rating,
    required this.cooked,
  });

  final String note;
  final int rating;
  final bool cooked;

  RecipeJournalEntry copyWith({
    String? note,
    int? rating,
    bool? cooked,
  }) {
    return RecipeJournalEntry(
      note: note ?? this.note,
      rating: rating ?? this.rating,
      cooked: cooked ?? this.cooked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'note': note,
      'rating': rating,
      'cooked': cooked,
    };
  }

  factory RecipeJournalEntry.fromJson(Map<String, dynamic> json) {
    return RecipeJournalEntry(
      note: json['note'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      cooked: json['cooked'] as bool? ?? false,
    );
  }
}

class DishRecipeSelection {
  const DishRecipeSelection({
    required this.dish,
    required this.recipe,
  });

  final Dish dish;
  final Recipe recipe;
}

class FavoriteSelection {
  const FavoriteSelection({
    required this.country,
    required this.dish,
    required this.recipe,
  });

  final CountryCuisine country;
  final Dish dish;
  final Recipe recipe;
}

class RecipeSelection {
  const RecipeSelection({
    required this.country,
    required this.dish,
    required this.recipe,
  });

  final CountryCuisine country;
  final Dish dish;
  final Recipe recipe;

  List<String> get searchableTerms => [
        country.nameRu,
        country.nameOriginal,
        dish.nameRu,
        dish.nameOriginal,
        ...dish.tags,
        ...recipe.ingredients,
      ].map((value) => value.toLowerCase()).toList(growable: false);
}

class RecipeFilters {
  const RecipeFilters({
    this.query = '',
    this.maxMinutes,
    this.type = 'all',
    this.requiredTags = const <String>{},
    this.maxSpiceLevel,
    this.allowSpicy = true,
    this.allowExotic = true,
    this.quickOnly = false,
    this.smallPortionsOnly = false,
  });

  final String query;
  final int? maxMinutes;
  final String type;
  final Set<String> requiredTags;
  final int? maxSpiceLevel;
  final bool allowSpicy;
  final bool allowExotic;
  final bool quickOnly;
  final bool smallPortionsOnly;

  RecipeFilters copyWith({
    String? query,
    int? maxMinutes,
    bool clearMaxMinutes = false,
    String? type,
    Set<String>? requiredTags,
    int? maxSpiceLevel,
    bool clearMaxSpiceLevel = false,
    bool? allowSpicy,
    bool? allowExotic,
    bool? quickOnly,
    bool? smallPortionsOnly,
  }) {
    return RecipeFilters(
      query: query ?? this.query,
      maxMinutes: clearMaxMinutes ? null : (maxMinutes ?? this.maxMinutes),
      type: type ?? this.type,
      requiredTags: requiredTags ?? this.requiredTags,
      maxSpiceLevel: clearMaxSpiceLevel ? null : (maxSpiceLevel ?? this.maxSpiceLevel),
      allowSpicy: allowSpicy ?? this.allowSpicy,
      allowExotic: allowExotic ?? this.allowExotic,
      quickOnly: quickOnly ?? this.quickOnly,
      smallPortionsOnly: smallPortionsOnly ?? this.smallPortionsOnly,
    );
  }

  bool matches(RecipeSelection selection) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isNotEmpty &&
        !selection.searchableTerms.any((value) => value.contains(normalizedQuery))) {
      return false;
    }
    if (type != 'all' && selection.dish.type != type) {
      return false;
    }
    if (maxMinutes != null && selection.recipe.minutes > maxMinutes!) {
      return false;
    }
    if (requiredTags.isNotEmpty &&
        !requiredTags.every((tag) => selection.dish.tags.contains(tag))) {
      return false;
    }
    if (maxSpiceLevel != null && selection.dish.spiceLevel > maxSpiceLevel!) {
      return false;
    }
    if (!allowSpicy && selection.dish.spiceLevel >= 2) {
      return false;
    }
    if (!allowExotic && selection.dish.exoticLevel >= 2) {
      return false;
    }
    if (quickOnly && selection.recipe.minutes > 30) {
      return false;
    }
    if (smallPortionsOnly && selection.recipe.servings > 2) {
      return false;
    }
    return true;
  }
}

String encodeShoppingItems(List<ShoppingItem> items) {
  return jsonEncode(items.map((item) => item.toJson()).toList());
}

List<ShoppingItem> decodeShoppingItems(String raw) {
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>))
      .toList();
}

String encodeJournalMap(Map<String, RecipeJournalEntry> journal) {
  return jsonEncode(
    journal.map((key, value) => MapEntry(key, value.toJson())),
  );
}

Map<String, RecipeJournalEntry> decodeJournalMap(String raw) {
  final map = jsonDecode(raw) as Map<String, dynamic>;
  return map.map(
    (key, value) => MapEntry(
      key,
      RecipeJournalEntry.fromJson(value as Map<String, dynamic>),
    ),
  );
}

enum Difficulty {
  easy('easy', 'Легко', '🟢'),
  medium('medium', 'Средне', '🟡'),
  hard('hard', 'Сложно', '🔴');

  const Difficulty(this.key, this.label, this.emoji);

  final String key;
  final String label;
  final String emoji;

  static Difficulty fromKey(String key) {
    return Difficulty.values.firstWhere(
      (difficulty) => difficulty.key == key,
      orElse: () => Difficulty.medium,
    );
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
