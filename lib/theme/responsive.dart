import 'package:eda_adventure/state/app_state.dart';
import 'package:flutter/widgets.dart';

bool isCompactLayout(BuildContext context, AppState appState) {
  if (appState.compactMode) {
    return true;
  }
  final size = MediaQuery.sizeOf(context);
  return size.height < 760 || size.width < 380;
}
