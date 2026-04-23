import 'package:eda_adventure/models/food_models.dart';
import 'package:eda_adventure/screens/random_country_screen.dart';
import 'package:eda_adventure/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('random country screen does not overflow in compact layout', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final errors = <FlutterErrorDetails>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      MaterialApp(
        home: RandomCountryScreen(
          countries: [_countrySample()],
          appState: AppState(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    FlutterError.onError = originalOnError;

    final overflowExceptions = errors
        .where((error) => error.exceptionAsString().contains('A RenderFlex overflowed'))
        .toList();

    expect(overflowExceptions, isEmpty);
    expect(find.text('Крутим глобус'), findsOneWidget);
  });
}

CountryCuisine _countrySample() {
  final easy = Recipe(
    id: 'sample_easy',
    difficulty: Difficulty.easy,
    cookingTime: '25 минут',
    summary: 'Быстрый вариант',
    ingredients: const ['рис, 150 г', 'курица, 200 г'],
    steps: const ['Подготовить ингредиенты', 'Приготовить на сковороде'],
    nutritionInfo: const NutritionInfo(calories: 500),
    budgetLevel: 1,
    source: 'test',
  );
  final medium = Recipe(
    id: 'sample_medium',
    difficulty: Difficulty.medium,
    cookingTime: '45 минут',
    summary: 'Средний вариант',
    ingredients: const ['рис, 200 г', 'овощи, 150 г'],
    steps: const ['Нарезать', 'Тушить'],
    nutritionInfo: const NutritionInfo(calories: 620),
    budgetLevel: 2,
    source: 'test',
  );
  final hard = Recipe(
    id: 'sample_hard',
    difficulty: Difficulty.hard,
    cookingTime: '1 час 20 минут',
    summary: 'Сложный вариант',
    ingredients: const ['рис, 250 г', 'говядина, 250 г'],
    steps: const ['Подготовить', 'Томить'],
    nutritionInfo: const NutritionInfo(calories: 760),
    budgetLevel: 3,
    source: 'test',
  );

  return CountryCuisine(
    id: 'sample_country',
    nameRu: 'Тестландия',
    nameOriginal: 'Testland',
    flag: '🏳️',
    continent: 'Европа',
    fact: 'Тестовый факт',
    dishes: [
      Dish(
        id: 'sample_dish',
        nameRu: 'Тестовое блюдо',
        nameOriginal: 'Test Dish',
        imageEmoji: '🍲',
        imageUrl: '',
        blurb: 'Тестовое описание',
        type: 'stew',
        tags: const ['быстрое'],
        spiceLevel: 1,
        exoticLevel: 0,
        pantryKeywords: const ['рис', 'курица'],
        recipesByDifficulty: {
          Difficulty.easy: easy,
          Difficulty.medium: medium,
          Difficulty.hard: hard,
        },
      ),
    ],
  );
}
