import 'package:flutter/material.dart';

class CategoryText extends StatelessWidget {
  final String text;

  const CategoryText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        text,
        style: theme.textTheme.labelLarge!
            .copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}
