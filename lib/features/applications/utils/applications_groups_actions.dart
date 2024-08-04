import 'package:flutter/cupertino.dart';
import 'package:minimum/features/applications/screens/applications_group_screen.dart';
import 'package:minimum/models/applications_group.dart';
import 'package:minimum/utils/listenable_actions.dart';

mixin class ApplicationsGroupsActionsListener {
  void didTapApplicationsGroup(ApplicationsGroup group) {}

  void didAddOrUpdateGroup(ApplicationsGroup group) {}

  void didRemoveGroup(ApplicationsGroup group) {}
}

class ApplicationsGroupsActions
    with ListenableActions<ApplicationsGroupsActionsListener> {
  void tap(BuildContext context, ApplicationsGroup group) {
    Navigator.of(context).pushNamed(
      ApplicationsGroupScreen.route,
      arguments: ApplicationsGroupArgumentsScreen(id: group.id),
    );
    notify(
      (listener) => listener.didTapApplicationsGroup(group),
    );
  }

  void addOrUpdate(ApplicationsGroup group) {
    notify((listener) => listener.didAddOrUpdateGroup(group));
  }

  void remove(ApplicationsGroup group) {
    notify((listener) => listener.didRemoveGroup(group));
  }
}
