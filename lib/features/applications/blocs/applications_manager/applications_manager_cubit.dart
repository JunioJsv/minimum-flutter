import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart'
    hide Entry;
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:minimum/features/applications/utils/applications_actions.dart';
import 'package:minimum/features/applications/utils/applications_groups_actions.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/models/application_event.dart';
import 'package:minimum/models/application_preferences.dart';
import 'package:minimum/models/applications_group.dart';
import 'package:minimum/models/entry.dart';
import 'package:minimum/models/order.dart';
import 'package:minimum/services/applications_manager_service.dart';

part 'applications_manager_state.dart';

class ApplicationsManagerCubit extends HydratedCubit<ApplicationsManagerState>
    with ApplicationsActionsListener, ApplicationsGroupsActionsListener {
  final ApplicationsManagerService service;
  final PreferencesManagerCubit preferences;
  final ApplicationsActions applicationsActions;
  final ApplicationsGroupsActions applicationsGroupsActions;

  ApplicationsManagerCubit(
    this.service,
    this.preferences,
    this.applicationsActions,
    this.applicationsGroupsActions,
  ) : super(ApplicationsManagerInitial()) {
    _subscriptions.add(
      preferences.stream.listen((preferences) {
        final state = this.state;
        if (state is! ApplicationsManagerFetchSuccess) return;
        final isShowingHidden = preferences.showHidden;
        if (isShowingHidden != state.isShowingHidden) {
          emit(state.copyWith(
            isShowingHidden: isShowingHidden,
          ));
        }
      }),
    );
    applicationsActions.addListener(this);
    applicationsGroupsActions.addListener(this);
    Future.microtask(() async {
      await for (final event in service.eventsStream) {
        await _onApplicationEvent(event);
      }
    });
  }

  final List<StreamSubscription> _subscriptions = [];

  Future<void> _onApplicationEvent(ApplicationEvent event) async {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    final type = event.type;
    final packages = event.packages;
    switch (type) {
      case ApplicationEventType.onPackageAdded:
        final package = packages.first;
        final application = await service.getApplication(package);
        emit(state.builder.addApplication(application).build());
        break;
      case ApplicationEventType.onPackageRemoved:
        final package = packages.first;
        emit(state.builder.removeApplication(package).build());
        break;
      case ApplicationEventType.onPackageChanged:
        final package = packages.first;
        final isEnabled = await service.isApplicationEnabled(package);
        _onApplicationEvent(
          event.copyWith(
            type: isEnabled
                ? ApplicationEventType.onPackageAdded
                : ApplicationEventType.onPackageRemoved,
          ),
        );
        break;
      case ApplicationEventType.onPackagesAvailable:
      // Todo implements onPackagesAvailable event
      case ApplicationEventType.onPackagesUnavailable:
      // Todo implements onPackagesUnavailable event
    }
  }

  @override
  void didTapApplication(Application application) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    if (application.preferences.isNew) {
      emit(
        state.builder
            .addOrUpdateApplicationPreferences(
              application.package,
              (preferences) => preferences.copyWith(isNew: false),
            )
            .build(),
      );
    }
  }

  @override
  void didToggleApplicationHide(Application application) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    final isHidden = application.preferences.isHidden;
    emit(
      state.builder
          .addOrUpdateApplicationPreferences(
            application.package,
            (preferences) => preferences.copyWith(isHidden: isHidden),
          )
          .build(),
    );
  }

  @override
  void didToggleApplicationPin(Application application) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    final isPinned = application.preferences.isPinned;
    emit(
      state.builder
          .addOrUpdateApplicationPreferences(
            application.package,
            (preferences) => preferences.copyWith(isPinned: isPinned),
          )
          .build(),
    );
  }

  @override
  void didTapApplicationsGroup(ApplicationsGroup group) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    if (group.isNew) {
      emit(
        state.builder
            .addOrUpdateGroup(
              group.copyWith(isNew: false),
            )
            .build(),
      );
    }
  }

  @override
  void didAddOrUpdateGroup(ApplicationsGroup group) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    emit(state.builder.addOrUpdateGroup(group).build());
  }

  @override
  void didRemoveGroup(ApplicationsGroup group) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    emit(state.builder.removeGroup(group.id).build());
  }

  Future<void> getInstalledApplications() async {
    final state = this.state;
    emit(ApplicationsManagerFetchRunning());
    try {
      final applications = await service.getInstalledApplications();
      emit(
        state is ApplicationsManagerFetchSuccess
            ? state.copyWith(applications: applications)
            : ApplicationsManagerFetchSuccess(applications: applications),
      );
    } catch (_, s) {
      emit(ApplicationsManagerFetchFailure());
      if (kDebugMode) {
        print(s);
      }
    }
  }

  void sort() {
    final state = this.state;
    if (state is ApplicationsManagerFetchSuccess) {
      emit(state.copyWith());
    }
  }

  @override
  Future<void> close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    applicationsActions.removeListener(this);
    applicationsGroupsActions.removeListener(this);
    return super.close();
  }

  @override
  ApplicationsManagerState? fromJson(Map<String, dynamic> json) {
    final order = Order.fromJson(json['order']);
    if (order != null) {
      Entry.orderBy = order;
    }

    try {
      return ApplicationsManagerFetchSuccess.fromJson(json).copyWith(
        isShowingHidden: preferences.state.showHidden,
      );
    } catch (_, s) {
      debugPrintStack(stackTrace: s, label: '$runtimeType');
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(ApplicationsManagerState state) {
    try {
      if (state is ApplicationsManagerFetchSuccess) {
        return state.toJson();
      }
    } catch (_, s) {
      debugPrintStack(stackTrace: s, label: '$runtimeType');
    }

    return null;
  }
}
