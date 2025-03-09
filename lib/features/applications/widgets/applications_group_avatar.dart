import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/application_avatar.dart';
import 'package:minimum/features/applications/widgets/applications_group_icon.dart';
import 'package:minimum/models/applications_group.dart';

class ApplicationsGroupAvatar extends StatelessWidget {
  final ApplicationsGroup group;

  const ApplicationsGroupAvatar({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        ApplicationsGroupIcon(components: group.components),
        if (group.isPinned)
          Align(
            alignment: Alignment.topRight * 2,
            child: ApplicationTag(
              background: theme.colorScheme.primary,
              foreground: theme.colorScheme.onPrimary,
              icon: Icons.push_pin,
            ),
          ),
        if (group.isNew)
          Align(
            alignment: Alignment.bottomRight * 2,
            child: ApplicationTag(
              background: theme.colorScheme.tertiary,
              foreground: theme.colorScheme.onTertiary,
              icon: Icons.new_releases,
            ),
          ),
      ],
    );
  }
}
