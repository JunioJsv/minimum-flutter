import 'package:flutter/material.dart';

class WarningContainer extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const WarningContainer({
    super.key,
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: kThemeAnimationDuration,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: color),
                Container(
                  width: constraints.maxWidth / 2,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    message,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: color),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
