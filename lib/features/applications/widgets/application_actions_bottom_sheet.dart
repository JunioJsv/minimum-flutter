import 'package:flutter/material.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';

class ApplicationActionsBottomSheet extends StatelessWidget {
  final Application application;

  const ApplicationActionsBottomSheet({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    final ApplicationsScreenState screen = dependencies();
    final applications = screen.applications;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: SizedBox.square(
            dimension: 24,
            child: ApplicationIcon(package: application.package),
          ),
          title: Text(
            application.label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.push_pin_outlined),
          title: Text(translation.pin),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(translation.info),
          onTap: () {
            applications.details(application);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: Text(translation.uninstall),
          onTap: () {
            applications.uninstall(application);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
