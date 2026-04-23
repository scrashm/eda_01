import 'dart:convert';

import 'package:eda_adventure/models/food_models.dart';
import 'package:flutter/services.dart';

class RecipeRepository {
  Future<List<CountryCuisine>> loadCountries() async {
    final raw = await rootBundle.loadString('assets/data/world_recipes.json');
    final Map<String, dynamic> jsonMap = jsonDecode(raw) as Map<String, dynamic>;
    final countries = (jsonMap['countries'] as List<dynamic>)
        .map((item) => CountryCuisine.fromJson(item as Map<String, dynamic>))
        .toList();
    return _enrichCountries(countries);
  }

  List<CountryCuisine> _enrichCountries(List<CountryCuisine> countries) {
    const metadata = <String, Map<String, dynamic>>{
      'greece_moussaka': {
        'imageUrl': 'https://loremflickr.com/800/1000/moussaka?lock=11',
        'type': 'bake',
        'tags': ['мясо', 'сытное'],
        'spiceLevel': 0,
        'exoticLevel': 1,
        'pantryKeywords': ['фарш', 'баклажан', 'картофель', 'сыр', 'томат']
      },
      'greece_souvlaki': {
        'imageUrl': 'https://loremflickr.com/800/1000/souvlaki?lock=12',
        'type': 'street',
        'tags': ['птица', 'мясо', 'быстрое'],
        'spiceLevel': 0,
        'exoticLevel': 0,
        'pantryKeywords': ['курица', 'свинина', 'йогурт', 'огурец', 'лимон']
      },
      'ethiopia_doro_wat': {
        'imageUrl': 'https://loremflickr.com/800/1000/chicken-stew?lock=13',
        'type': 'stew',
        'tags': ['птица', 'острое'],
        'spiceLevel': 3,
        'exoticLevel': 2,
        'pantryKeywords': ['курица', 'лук', 'яйцо', 'томат', 'чеснок']
      },
      'ethiopia_shiro': {
        'imageUrl': 'https://loremflickr.com/800/1000/chickpea-stew?lock=14',
        'type': 'stew',
        'tags': ['вегетарианское', 'бюджетное'],
        'spiceLevel': 2,
        'exoticLevel': 2,
        'pantryKeywords': ['нут', 'лук', 'чеснок', 'томат']
      },
      'japan_ramen': {
        'imageUrl': 'https://loremflickr.com/800/1000/ramen?lock=15',
        'type': 'soup',
        'tags': ['птица', 'мясо', 'сытное'],
        'spiceLevel': 1,
        'exoticLevel': 2,
        'pantryKeywords': ['лапша', 'яйцо', 'курица', 'бульон', 'соевый соус']
      },
      'japan_katsu_curry': {
        'imageUrl': 'https://loremflickr.com/800/1000/japanese-curry?lock=16',
        'type': 'rice',
        'tags': ['птица', 'мясо', 'сытное'],
        'spiceLevel': 1,
        'exoticLevel': 1,
        'pantryKeywords': ['курица', 'свинина', 'рис', 'карри', 'панировка']
      },
      'mexico_tacos': {
        'imageUrl': 'https://loremflickr.com/800/1000/tacos?lock=17',
        'type': 'street',
        'tags': ['мясо', 'острое', 'быстрое'],
        'spiceLevel': 2,
        'exoticLevel': 1,
        'pantryKeywords': ['фарш', 'курица', 'говядина', 'тортилья', 'сыр']
      },
      'mexico_quesadilla': {
        'imageUrl': 'https://loremflickr.com/800/1000/quesadilla?lock=18',
        'type': 'street',
        'tags': ['быстрое', 'бюджетное'],
        'spiceLevel': 1,
        'exoticLevel': 0,
        'pantryKeywords': ['тортилья', 'сыр', 'курица', 'томат', 'фасоль']
      },
      'india_butter_chicken': {
        'imageUrl': 'https://loremflickr.com/800/1000/butter-chicken?lock=19',
        'type': 'curry',
        'tags': ['птица', 'острое'],
        'spiceLevel': 2,
        'exoticLevel': 2,
        'pantryKeywords': ['курица', 'сливки', 'томат', 'йогурт', 'рис']
      },
      'india_biryani': {
        'imageUrl': 'https://loremflickr.com/800/1000/biryani?lock=20',
        'type': 'rice',
        'tags': ['птица', 'мясо', 'сытное'],
        'spiceLevel': 2,
        'exoticLevel': 2,
        'pantryKeywords': ['рис', 'курица', 'лук', 'йогурт', 'специи']
      },
      'italy_carbonara': {
        'imageUrl': 'https://loremflickr.com/800/1000/carbonara?lock=21',
        'type': 'pasta',
        'tags': ['мясо', 'быстрое'],
        'spiceLevel': 0,
        'exoticLevel': 0,
        'pantryKeywords': ['паста', 'яйцо', 'сыр', 'бекон']
      },
      'italy_risotto': {
        'imageUrl': 'https://loremflickr.com/800/1000/risotto?lock=22',
        'type': 'rice',
        'tags': ['вегетарианское', 'сытное'],
        'spiceLevel': 0,
        'exoticLevel': 0,
        'pantryKeywords': ['рис', 'грибы', 'сыр', 'лук']
      },
      'thailand_tom_yum': {
        'imageUrl': 'https://loremflickr.com/800/1000/tom-yum?lock=23',
        'type': 'soup',
        'tags': ['рыба', 'острое'],
        'spiceLevel': 3,
        'exoticLevel': 3,
        'pantryKeywords': ['креветки', 'грибы', 'лайм', 'бульон']
      },
      'thailand_pad_thai': {
        'imageUrl': 'https://loremflickr.com/800/1000/pad-thai?lock=24',
        'type': 'noodles',
        'tags': ['рыба', 'быстрое', 'острое'],
        'spiceLevel': 2,
        'exoticLevel': 2,
        'pantryKeywords': ['лапша', 'креветки', 'яйцо', 'арахис', 'лайм']
      },
      'morocco_tagine': {
        'imageUrl': 'https://loremflickr.com/800/1000/tagine?lock=25',
        'type': 'stew',
        'tags': ['мясо', 'сытное'],
        'spiceLevel': 1,
        'exoticLevel': 2,
        'pantryKeywords': ['курица', 'баранина', 'лук', 'курага', 'нут']
      },
      'morocco_couscous': {
        'imageUrl': 'https://loremflickr.com/800/1000/couscous?lock=26',
        'type': 'grain',
        'tags': ['вегетарианское', 'бюджетное'],
        'spiceLevel': 1,
        'exoticLevel': 1,
        'pantryKeywords': ['кускус', 'морковь', 'нут', 'кабачок']
      },
      'korea_kimchi_jjigae': {
        'imageUrl': 'https://loremflickr.com/800/1000/kimchi-stew?lock=27',
        'type': 'soup',
        'tags': ['мясо', 'острое'],
        'spiceLevel': 3,
        'exoticLevel': 2,
        'pantryKeywords': ['кимчи', 'свинина', 'тофу', 'лук']
      },
      'korea_bibimbap': {
        'imageUrl': 'https://loremflickr.com/800/1000/bibimbap?lock=28',
        'type': 'rice',
        'tags': ['мясо', 'вегетарианское', 'быстрое'],
        'spiceLevel': 1,
        'exoticLevel': 1,
        'pantryKeywords': ['рис', 'морковь', 'яйцо', 'говядина', 'шпинат']
      },
      'france_ratatouille': {
        'imageUrl': 'https://loremflickr.com/800/1000/ratatouille?lock=29',
        'type': 'vegetable',
        'tags': ['вегетарианское', 'бюджетное'],
        'spiceLevel': 0,
        'exoticLevel': 0,
        'pantryKeywords': ['кабачок', 'баклажан', 'томат', 'перец']
      },
      'france_onion_soup': {
        'imageUrl': 'https://loremflickr.com/800/1000/onion-soup?lock=30',
        'type': 'soup',
        'tags': ['вегетарианское', 'бюджетное'],
        'spiceLevel': 0,
        'exoticLevel': 0,
        'pantryKeywords': ['лук', 'сыр', 'багет', 'бульон']
      },
    };

    return countries
        .map(
          (country) => country.copyWith(
            dishes: country.dishes.map((dish) {
              final info = metadata[dish.id];
              if (info == null) {
                return dish;
              }
              return dish.copyWith(
                imageUrl: info['imageUrl'] as String,
                type: info['type'] as String,
                tags: List<String>.from(info['tags'] as List<dynamic>),
                spiceLevel: info['spiceLevel'] as int,
                exoticLevel: info['exoticLevel'] as int,
                pantryKeywords: List<String>.from(info['pantryKeywords'] as List<dynamic>),
              );
            }).toList(),
          ),
        )
        .toList();
  }
}
