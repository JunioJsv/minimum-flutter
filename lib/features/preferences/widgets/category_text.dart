import 'package:flutter/material.dart';

class CategoryText extends StatelessWidget {
  final String text;

  const CategoryText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: theme.textTheme.labelLarge!
            .copyWith(color: theme.colorScheme.onSurface),
      ),
    );
  }
}