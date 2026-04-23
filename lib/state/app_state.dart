import 'package:eda_adventure/models/food_models.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  static const _onboardingKey = 'onboarding_seen';
  static const _historyKey = 'history_ids';
  static const _favoritesKey = 'favorite_recipe_ids';
  static const _compactModeKey = 'compact_mode';
  static const _lastRecipeKey = 'last_recipe_id';
  static const _shoppingListKey = 'shopping_list';
  static const _journalKey = 'recipe_journal';

  late final SharedPreferences _prefs;
  bool onboardingSeen = false;
  List<String> historyIds = [];
  Set<String> favoriteRecipeIds = <String>{};
  bool compactMode = false;
  String? lastRecipeId;
  List<ShoppingItem> shoppingList = <ShoppingItem>[];
  Map<String, RecipeJournalEntry> recipeJournal = <String, RecipeJournalEntry>{};

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    onboardingSeen = _prefs.getBool(_onboardingKey) ?? false;
    historyIds = _prefs.getStringList(_historyKey) ?? <String>[];
    favoriteRecipeIds = (_prefs.getStringList(_favoritesKey) ?? <String>[]).toSet();
    compactMode = _prefs.getBool(_compactModeKey) ?? false;
    lastRecipeId = _prefs.getString(_lastRecipeKey);
    final shoppingRaw = _prefs.getString(_shoppingListKey);
    if (shoppingRaw != null && shoppingRaw.isNotEmpty) {
      shoppingList = decodeShoppingItems(shoppingRaw);
    }
    final journalRaw = _prefs.getString(_journalKey);
    if (journalRaw != null && journalRaw.isNotEmpty) {
      recipeJournal = decodeJournalMap(journalRaw);
    }
    notifyListeners();
  }

  Future<void> markOnboardingSeen() async {
    onboardingSeen = true;
    await _prefs.setBool(_onboardingKey, true);
    notifyListeners();
  }

  Future<void> addHistory(String countryId) async {
    historyIds = [
      countryId,
      ...historyIds.where((id) => id != countryId),
    ].take(40).toList();
    await _prefs.setStringList(_historyKey, historyIds);
    notifyListeners();
  }

  Future<void> removeHistoryAt(int index) async {
    if (index < 0 || index >= historyIds.length) {
      return;
    }
    historyIds = [...historyIds]..removeAt(index);
    await _prefs.setStringList(_historyKey, historyIds);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    historyIds = <String>[];
    await _prefs.setStringList(_historyKey, historyIds);
    notifyListeners();
  }

  Future<void> toggleFavorite(String recipeId) async {
    if (favoriteRecipeIds.contains(recipeId)) {
      favoriteRecipeIds.remove(recipeId);
    } else {
      favoriteRecipeIds.add(recipeId);
    }
    await _prefs.setStringList(_favoritesKey, favoriteRecipeIds.toList());
    notifyListeners();
  }

  Future<void> setCompactMode(bool value) async {
    compactMode = value;
    await _prefs.setBool(_compactModeKey, value);
    notifyListeners();
  }

  Future<void> setLastRecipe(String recipeId) async {
    lastRecipeId = recipeId;
    await _prefs.setString(_lastRecipeKey, recipeId);
    notifyListeners();
  }

  RecipeJournalEntry entryForRecipe(String recipeId) {
    return recipeJournal[recipeId] ??
        const RecipeJournalEntry(
          note: '',
          rating: 0,
          cooked: false,
        );
  }

  Future<void> updateRecipeNote(String recipeId, String note) async {
    recipeJournal = {
      ...recipeJournal,
      recipeId: entryForRecipe(recipeId).copyWith(note: note),
    };
    await _prefs.setString(_journalKey, encodeJournalMap(recipeJournal));
    notifyListeners();
  }

  Future<void> updateRecipeRating(String recipeId, int rating) async {
    recipeJournal = {
      ...recipeJournal,
      recipeId: entryForRecipe(recipeId).copyWith(rating: rating),
    };
    await _prefs.setString(_journalKey, encodeJournalMap(recipeJournal));
    notifyListeners();
  }

  Future<void> updateCooked(String recipeId, bool cooked) async {
    recipeJournal = {
      ...recipeJournal,
      recipeId: entryForRecipe(recipeId).copyWith(cooked: cooked),
    };
    await _prefs.setString(_journalKey, encodeJournalMap(recipeJournal));
    notifyListeners();
  }

  Future<void> addRecipeToShoppingList(Recipe recipe) async {
    final itemsByKey = {for (final item in shoppingList) item.key: item};
    for (final ingredient in recipe.parsedIngredients) {
      final key = ingredient.name.toLowerCase();
      final existing = itemsByKey[key];
      if (existing == null) {
        itemsByKey[key] = ShoppingItem(
          key: key,
          name: ingredient.name,
          displayName: ingredient.name,
          variants: ingredient.display.isEmpty ? [ingredient.name] : [ingredient.display],
          recipeIds: [recipe.id],
          count: 1,
        );
      } else {
        itemsByKey[key] = existing.copyWith(
          variants: {...existing.variants, ingredient.display}.toList()..sort(),
          recipeIds: {...existing.recipeIds, recipe.id}.toList(),
          count: existing.count + 1,
        );
      }
    }
    shoppingList = itemsByKey.values.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    await _prefs.setString(_shoppingListKey, encodeShoppingItems(shoppingList));
    notifyListeners();
  }

  Future<void> removeShoppingItem(String key) async {
    shoppingList = shoppingList.where((item) => item.key != key).toList();
    await _prefs.setString(_shoppingListKey, encodeShoppingItems(shoppingList));
    notifyListeners();
  }

  Future<void> clearShoppingList() async {
    shoppingList = <ShoppingItem>[];
    await _prefs.setString(_shoppingListKey, encodeShoppingItems(shoppingList));
    notifyListeners();
  }
}
