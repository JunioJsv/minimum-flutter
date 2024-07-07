import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final isApplicationPinned = application.preferences.isPinned;
    final isApplicationHidden = application.preferences.isHidden;
    final Application(:label, :package, :version) = application;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: SizedBox.square(
            dimension: 24,
            child: ApplicationIcon(package: package),
          ),
          title: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(
            '${translation.version} $version',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              final text = '$package:$version';
              Clipboard.setData(ClipboardData(text: text));
            },
          ),
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(Icons.push_pin_outlined),
          title: Text(
            isApplicationPinned ? translation.unpin : translation.pin,
          ),
          onTap: () {
            Navigator.pop(context);
            screen.onToggleApplicationPin(context, application);
          },
        ),
        ListTile(
          leading: Icon(
            isApplicationHidden
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          title: Text(
            isApplicationHidden ? translation.unhide : translation.hide,
          ),
          onTap: () {
            Navigator.pop(context);
            screen.onToggleApplicationHide(context, application);
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
