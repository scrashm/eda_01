# Еда-приключение

Flutter-приложение для подбора блюд мира: случайная страна, выбор рецептов по фильтрам, избранное, история, список покупок и заметки по рецептам.

## Костяк приложения

### Основной пользовательский сценарий

1. Первый запуск -> онбординг.
2. Экран `Крутим глобус`:
   - случайный выбор страны;
   - фильтр по континенту;
   - быстрые переходы в режимы подбора.
3. Экран страны -> список блюд.
4. Экран рецепта:
   - ингредиенты и шаги;
   - добавление в избранное;
   - копирование рецепта в буфер.
5. Нижняя навигация:
   - Главная;
   - Избранное;
   - История;
   - Настройки.

### Дополнительные режимы

- `Быстрый режим` (до 30 минут, малые порции).
- `Подбор рецептов` с фильтрами (время, тип, теги, острота, экзотичность, порции).
- `Из того, что есть` (подбор по ингредиентам).
- `Список покупок` (агрегация ингредиентов по рецептам).
- `Подборки` (ужин на двоих, гости, выходной эксперимент).

## Текущее состояние качества

- `flutter analyze` -> `No issues found`.
- `flutter test` -> `All tests passed` (1 widget test).
- `flutter run -d windows` запускается, но в рантайме обнаружен `RenderFlex overflow` в `lib/screens/random_country_screen.dart` (карточка shortcut на компактной высоте).
- Android-сборка выполняется, но установка на устройство может падать с `INSTALL_FAILED_USER_RESTRICTED` (ограничение/подтверждение на стороне устройства).
- Есть предупреждение Flutter о будущей миграции на Built-in Kotlin и плагине `shared_preferences_android`.

## Стек

- Flutter / Dart
- Material 3
- `shared_preferences`
- локальные JSON assets (`assets/data/world_recipes.json`)

## Структура проекта

```text
lib/
  app.dart
  main.dart
  models/
  data/
  state/
  screens/
  widgets/
  theme/
assets/
  data/world_recipes.json
docs/
  NEXT_STEPS_TZ.md
test/
  widget_test.dart
```

## Запуск проекта

### 1) Установить зависимости

Если `flutter` в `PATH`:

```bash
flutter pub get
```

Если `flutter` не в `PATH` (на этой машине рабочий путь):

```powershell
& "C:\Users\abs\flutter\bin\flutter.bat" pub get
```

### 2) Проверить окружение

```powershell
& "C:\Users\abs\flutter\bin\flutter.bat" doctor -v
```

### 3) Посмотреть устройства

```powershell
& "C:\Users\abs\flutter\bin\flutter.bat" devices
```

### 4) Запустить приложение

Windows:

```powershell
& "C:\Users\abs\flutter\bin\flutter.bat" run -d windows
```

Android (устройство/эмулятор):

```powershell
& "C:\Users\abs\flutter\bin\flutter.bat" run -d android
```

## Частые проблемы запуска

### Android: `INSTALL_FAILED_USER_RESTRICTED`

- разблокировать телефон во время установки;
- подтвердить системный диалог установки/отладки;
- включить в режиме разработчика `Install via USB` (особенно MIUI/HyperOS);
- при проблемах с wireless debugging переподключить устройство или запустить по USB.

### Предупреждение о Kotlin Gradle Plugin

Сейчас это предупреждение, но в будущих версиях Flutter станет ошибкой сборки. Нужно:

- мигрировать Android app-модуль на Built-in Kotlin;
- обновить зависимости до версий без применения устаревшего KGP (в частности `shared_preferences_android` при выходе совместимой версии).

## Полезные команды

```powershell
& "C:\Users\abs\flutter\bin\flutter.bat" analyze
& "C:\Users\abs\flutter\bin\flutter.bat" test
& "C:\Users\abs\flutter\bin\flutter.bat" build apk
```
