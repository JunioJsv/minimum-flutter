import 'package:flutter/material.dart';
import 'package:minimum/features/applications/screens/create_applications_group_screen.dart';
import 'package:minimum/features/applications/utils/applications_groups_actions.dart';
import 'package:minimum/features/applications/widgets/applications_group_icon.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/applications_group.dart';
import 'package:minimum/widgets/confirmation_dialog.dart';

class ApplicationsGroupActionsBottomSheet extends StatelessWidget {
  final ApplicationsGroup group;

  const ApplicationsGroupActionsBottomSheet({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    final applicationsGroupsActions = dependencies<ApplicationsGroupsActions>();
    final ApplicationsGroup(:label, :components, :description, :isPinned) =
        group;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: SizedBox.square(
            dimension: 24,
            child: ApplicationsGroupIcon(components: components),
          ),
          title: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
          subtitle:
              description != null
                  ? Text(
                    description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                  : null,
          trailing: IconButton(
            icon: const Icon(Icons.dashboard_customize_outlined),
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                CreateApplicationsGroupScreen.route,
                arguments: CreateApplicationsGroupScreenArguments(
                  initial: group,
                  onConfirm: (group) {
                    applicationsGroupsActions.addOrUpdate(group);
                  },
                ),
              );
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.push_pin_outlined),
          title: Text(isPinned ? translation.unpin : translation.pin),
          onTap: () {
            Navigator.pop(context);
            applicationsGroupsActions.togglePin(group);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: Text(translation.delete),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) {
                return ConfirmationDialog(
                  title: translation.wantDeleteGroup,
                  message: translation.thatGroupDeleteHint(that: label),
                  confirm: translation.confirm,
                  decline: translation.cancel,
                );
              },
            ).then((confirmation) {
              if (confirmation == true) {
                applicationsGroupsActions.remove(group);
              }
            });
          },
        ),
      ],
    );
  }
}
