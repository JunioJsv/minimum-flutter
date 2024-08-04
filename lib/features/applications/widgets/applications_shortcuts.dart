import 'package:flutter/material.dart';
import 'package:minimum/features/applications/blocs/applications_manager/applications_manager_cubit.dart';
import 'package:minimum/features/applications/screens/create_applications_group_screen.dart';
import 'package:minimum/features/applications/utils/applications_groups_actions.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/entry.dart';
import 'package:minimum/models/order.dart';

class ApplicationsShortcuts extends StatelessWidget {
  const ApplicationsShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    final applications = dependencies<ApplicationsManagerCubit>();
    final applicationsGroupsActions = dependencies<ApplicationsGroupsActions>();
    final translation = context.translations;
    return SingleChildScrollView(
      child: Row(
        children: [
          StatefulBuilder(
            builder: (context, setState) {
              return ActionChip(
                label: Text(translation.ordering),
                avatar: Icon(
                  Entry.orderBy == Order.desc
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                ),
                onPressed: () {
                  setState(() {
                    Entry.orderBy = Entry.orderBy.toggle();
                  });
                  applications.sort();
                },
              );
            },
          ),
          const SizedBox(width: 8),
          ActionChip(
            label: Text(translation.createGroup),
            avatar: const Icon(Icons.dashboard_customize_outlined),
            onPressed: () {
              Navigator.pushNamed(
                context,
                CreateApplicationsGroupScreen.route,
                arguments: CreateApplicationsGroupScreenArguments(
                  onConfirm: applicationsGroupsActions.addOrUpdate,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
