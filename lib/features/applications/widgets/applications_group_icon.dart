import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';

class ApplicationsGroupIcon extends StatelessWidget {
  final Set<String> components;

  const ApplicationsGroupIcon({super.key, required this.components});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grid = components.take(4).slices(2);
    return Container(
      constraints: const BoxConstraints(maxHeight: 48, maxWidth: 48),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          for (final row in grid)
            Expanded(
              child: Row(
                children: [
                  for (final component in row)
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ApplicationIcon(
                          key: ValueKey(component),
                          component: component,
                          shadow: false,
                        ),
                      ),
                    ),
                  if (row.length == 1) const Spacer(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
