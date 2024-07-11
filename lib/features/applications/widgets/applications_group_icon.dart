import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';

class ApplicationsGroupIcon extends StatelessWidget {
  final Set<String> packages;

  const ApplicationsGroupIcon({
    super.key,
    required this.packages,
  }) : assert(packages.length >= 2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grid = packages.take(4).slices(2);
    return Container(
      constraints: const BoxConstraints(maxHeight: 48, maxWidth: 48),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (final row in grid)
            Expanded(
              child: Row(
                children: [
                  for (final package in row)
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ApplicationIcon(package: package),
                      ),
                    )
                ],
              ),
            )
        ],
      ),
    );
  }
}
