import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minimum/features/applications/utils/applications_actions.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';
import 'package:minimum/features/icon_packs/screens/icon_pack_drawable_selector_screen.dart';
import 'package:minimum/features/icon_packs/screens/icon_pack_selector_screen.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/services/local_authentication_service.dart';
import 'package:minimum/widgets/confirmation_dialog.dart';

class ApplicationActionsBottomSheet extends StatelessWidget {
  final Application application;

  const ApplicationActionsBottomSheet({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    final applicationsActions = dependencies<ApplicationsActions>();
    final isApplicationPinned = application.preferences.isPinned;
    final isApplicationHidden = application.preferences.isHidden;
    final Application(:label, :package, :component, :version) = application;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: SizedBox.square(
            dimension: 24,
            child: ApplicationIcon(component: component),
          ),
          title: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
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
            applicationsActions.togglePin(application);
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
          onTap: () async {
            final isHidden = !application.preferences.isHidden;
            final isDeviceSecure =
                await dependencies<LocalAuthenticationService>()
                    .isDeviceSecure();
            if (!isDeviceSecure && isHidden) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder:
                      (context) => ConfirmationDialog(
                        icon: const Icon(Icons.visibility_off_outlined),
                        title: translation.lockscreenRequired,
                        message: translation.setupLockscreen(
                          to: translation.hideApplications.toLowerCase(),
                        ),
                        confirm: translation.understood,
                      ),
                );
              });
              return;
            }
            if (context.mounted) Navigator.pop(context);
            applicationsActions.toggleHide(application);
          },
        ),
        ListTile(
          leading: const Icon(Icons.format_paint_outlined),
          title: Text(translation.changeIcon),
          onTap:
              () => Navigator.pushReplacementNamed(
                context,
                IconPackSelectorScreen.route,
                arguments: IconPackSelectorScreenArguments(
                  defaultComponent: application.component,
                  onSelect: (context, iconPack) {
                    if (iconPack == null) {
                      Navigator.pop(context);
                      applicationsActions.setIcon(application, null);
                      return;
                    }
                    Navigator.pushNamed(
                      context,
                      IconPackDrawableSelectorScreen.route,
                      arguments: IconPackDrawableSelectorScreenArguments(
                        iconPack: iconPack,
                        onSelect: (drawable) {
                          Navigator.pop(context);
                          applicationsActions.setIcon(application, drawable);
                        },
                      ),
                    );
                  },
                ),
              ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(translation.info),
          onTap: () {
            applicationsActions.openDetails(application);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: Text(translation.uninstall),
          onTap: () {
            applicationsActions.uninstall(application);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
