import 'package:eda_adventure/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('onboarding screen shows intro text and start button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(
          onStart: () async {},
          child: const SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Еда-\nприключение'), findsOneWidget);
    expect(find.text('Погнали'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
