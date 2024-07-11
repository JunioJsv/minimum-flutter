import 'package:flutter/material.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/features/applications/screens/create_applications_group_screen.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/order.dart';

class ApplicationsShortcuts extends StatelessWidget {
  const ApplicationsShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    final ApplicationsScreenState screen = dependencies();
    final applications = screen.applications;
    final translation = context.translations;
    return SingleChildScrollView(
      child: Row(
        children: [
          ValueListenableBuilder(
            valueListenable: applications.order,
            builder: (context, order, _) {
              return ActionChip(
                label: Text(translation.ordering),
                avatar: Icon(
                  order == Order.desc
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                ),
                onPressed: () {
                  applications.order.value = order.toggle();
                  applications.sort();
                },
              );
            },
          ),
          const SizedBox(width: 8),
          ActionChip(
            label: Text(translation.createGroup),
            avatar: const Icon(Icons.apps),
            onPressed: () {
              Navigator.pushNamed(
                context,
                CreateApplicationsGroupScreen.route,
                arguments: CreateApplicationsGroupScreenArguments(
                  onConfirm: (title, description, packages) {},
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
