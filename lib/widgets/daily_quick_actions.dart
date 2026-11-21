import 'package:flutter/material.dart' hide Text;
import '../i18n/text.dart';

/// GP-01: Ana ekrandan günlük kayıt işlemlerine hızlı erişim.
class DailyQuickActions extends StatelessWidget {
  const DailyQuickActions({
    super.key,
    required this.onFeeding,
    required this.onSleep,
    required this.onDiaper,
    required this.onMeasurement,
  });

  final VoidCallback onFeeding;
  final VoidCallback onSleep;
  final VoidCallback onDiaper;
  final VoidCallback onMeasurement;

  @override
  Widget build(BuildContext context) {
    final actions = <({String title, IconData icon, VoidCallback onTap})>[
      (title: 'Beslenme', icon: Icons.restaurant_rounded, onTap: onFeeding),
      (title: 'Uyku', icon: Icons.bedtime_rounded, onTap: onSleep),
      (title: 'Bez', icon: Icons.child_care_rounded, onTap: onDiaper),
      (title: 'Ölçüm', icon: Icons.monitor_weight_rounded, onTap: onMeasurement),
    ];

    return Semantics(
      label: 'Günlük hızlı kayıt işlemleri',
      child: LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final action in actions)
              SizedBox(
                width: constraints.maxWidth < 360
                    ? (constraints.maxWidth - 8) / 2
                    : (constraints.maxWidth - 24) / 4,
                child: OutlinedButton(
                  onPressed: action.onTap,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(action.icon, size: 24),
                      const SizedBox(height: 6),
                      Text(action.title, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
