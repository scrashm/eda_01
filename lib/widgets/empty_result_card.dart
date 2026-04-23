import 'package:flutter/material.dart';

class EmptyResultCard extends StatelessWidget {
  const EmptyResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Text('Выбери страну', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(
              'Нажми на круг и открой меню страны.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
