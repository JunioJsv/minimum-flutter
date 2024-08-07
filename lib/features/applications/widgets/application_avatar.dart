import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';
import 'package:minimum/models/application.dart';

class ApplicationAvatar extends StatelessWidget {
  final Application application;

  const ApplicationAvatar({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preferences = application.preferences;
    return Stack(
      alignment: Alignment.center,
      children: [
        ApplicationIcon(component: application.component),
        if (preferences.isPinned)
          Align(
            alignment: Alignment.topRight * 2,
            child: ApplicationTag(
              background: theme.colorScheme.primary,
              foreground: theme.colorScheme.onPrimary,
              icon: Icons.push_pin,
            ),
          ),
        if (preferences.isHidden)
          Align(
            alignment: Alignment.topLeft * 2,
            child: ApplicationTag(
              background: theme.colorScheme.secondary,
              foreground: theme.colorScheme.onSecondary,
              icon: Icons.visibility_off,
            ),
          ),
        if (preferences.isNew)
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

class ApplicationTag extends StatelessWidget {
  final Color background;
  final Color foreground;

  final IconData icon;

  const ApplicationTag({
    super.key,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 28,
      child: Card(
        color: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Icon(
              icon,
              color: foreground,
              size: constraints.maxWidth - 8,
            );
          },
        ),
      ),
    );
  }
}
