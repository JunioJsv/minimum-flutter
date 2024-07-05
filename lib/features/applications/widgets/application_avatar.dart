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
        ApplicationIcon(package: application.package),
        if (preferences.isPinned)
          Align(
            alignment: Alignment.topRight * 2,
            child: _ApplicationTag(
              background: theme.colorScheme.primary,
              foreground: theme.colorScheme.onPrimary,
              icon: Icons.push_pin,
            ),
          )
      ],
    );
  }
}

class _ApplicationTag extends StatelessWidget {
  final Color background;
  final Color foreground;

  final IconData icon;

  const _ApplicationTag({
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
