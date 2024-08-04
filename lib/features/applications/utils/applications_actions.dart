import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/application_actions_bottom_sheet.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/services/applications_manager_service.dart';
import 'package:minimum/utils/listenable_actions.dart';

mixin class ApplicationsActionsListener {
  void didTapApplication(Application application) {}

  void didLongTapApplication(Application application) {}

  void didToggleApplicationHide(Application application) {}

  void didToggleApplicationPin(Application application) {}

  void didOpenApplicationDetails(Application application) {}

  void didUninstallApplication(Application application) {}
}

class ApplicationsActions with ListenableActions<ApplicationsActionsListener> {
  late final service = dependencies<ApplicationsManagerService>();

  void toggleHide(Application application) {
    final preferences = application.preferences;
    final updated = application.copyWith(
      preferences: preferences.copyWith(isHidden: !preferences.isHidden),
    );
    notify(
      (listener) => listener.didToggleApplicationHide(updated),
    );
  }

  void togglePin(Application application) {
    final preferences = application.preferences;
    final updated = application.copyWith(
      preferences: preferences.copyWith(isPinned: !preferences.isPinned),
    );
    notify(
      (listener) => listener.didToggleApplicationPin(updated),
    );
  }

  void longTap(BuildContext context, Application application) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ApplicationActionsBottomSheet(application: application);
      },
    );
    notify(
      (listener) => listener.didLongTapApplication(application),
    );
  }

  void tap(Application application) {
    service.launchApplication(application.package);
    notify(
      (listener) => listener.didLongTapApplication(application),
    );
  }

  void openDetails(Application application) {
    service.openApplicationDetails(application.package);
    notify(
      (listener) => listener.didOpenApplicationDetails(application),
    );
  }

  void uninstall(Application application) {
    service.uninstallApplication(application.package);
    notify(
      (listener) => listener.didUninstallApplication(application),
    );
  }
}
