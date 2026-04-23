import 'package:eda_adventure/models/food_models.dart';

List<RecipeSelection> buildRecipeSelections(List<CountryCuisine> countries) {
  return countries
      .expand(
        (country) => country.dishes.expand(
          (dish) => dish.recipesByDifficulty.values.map(
            (recipe) => RecipeSelection(
              country: country,
              dish: dish,
              recipe: recipe,
            ),
          ),
        ),
      )
      .toList();
}

List<RecipeSelection> buildCuratedCollection(
  List<RecipeSelection> selections,
  String collectionId,
) {
  final lower = <String, bool Function(RecipeSelection)>{
    'dinner_for_two': (selection) =>
        selection.recipe.servings <= 2 && selection.recipe.minutes <= 60,
    'guests_arrived': (selection) =>
        selection.recipe.servings >= 3 && selection.recipe.minutes <= 90,
    'weekend_experiment': (selection) =>
        selection.recipe.minutes >= 60 || selection.recipe.difficulty == Difficulty.hard,
  };

  final predicate = lower[collectionId];
  if (predicate == null) {
    return selections;
  }

  return selections.where(predicate).toList()
    ..sort((a, b) => a.recipe.minutes.compareTo(b.recipe.minutes));
}

List<String> collectPantryKeywords(List<CountryCuisine> countries) {
  final keywords = countries
      .expand((country) => country.dishes)
      .expand((dish) => dish.pantryKeywords)
      .toSet()
      .toList()
    ..sort();
  return keywords;
}

RecipeSelection? findRecipeSelectionById(
  List<CountryCuisine> countries,
  String? recipeId,
) {
  if (recipeId == null) {
    return null;
  }

  for (final country in countries) {
    for (final dish in country.dishes) {
      for (final recipe in dish.recipesByDifficulty.values) {
        if (recipe.id == recipeId) {
          return RecipeSelection(
            country: country,
            dish: dish,
            recipe: recipe,
          );
        }
      }
    }
  }

  return null;
}
