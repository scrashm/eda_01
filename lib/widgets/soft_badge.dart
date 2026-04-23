import 'package:eda_adventure/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SoftBadge extends StatelessWidget {
  const SoftBadge({
    super.key,
    required this.icon,
    required this.label,
  });

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$icon  $label',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
