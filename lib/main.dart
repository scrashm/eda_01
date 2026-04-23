import 'package:eda_adventure/app.dart';
import 'package:eda_adventure/data/recipe_repository.dart';
import 'package:eda_adventure/state/app_state.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = RecipeRepository();
  final appState = AppState();

  final countries = await repository.loadCountries();
  await appState.load();

  runApp(EdaAdventureApp(
    appState: appState,
    countries: countries,
  ));
}
