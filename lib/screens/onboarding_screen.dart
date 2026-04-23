import 'package:eda_adventure/widgets/gradient_background.dart';
import 'package:eda_adventure/widgets/soft_badge.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.onStart,
    required this.child,
  });

  final Future<void> Function() onStart;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFE8E1D7)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SoftBadge(icon: '🍲', label: 'Кулинарная рулетка'),
                      const SizedBox(height: 24),
                      Text('Еда-\nприключение', style: theme.textTheme.headlineLarge),
                      const SizedBox(height: 18),
                      Text(
                        'Жми, получай страну и готовь как местный.',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Сегодня рамен. Завтра мусака. Всё честно.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await onStart();
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(builder: (_) => child),
                      );
                    },
                    child: const Text('Погнали'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
