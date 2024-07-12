import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart'
    hide Entry;
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/models/application_event.dart';
import 'package:minimum/models/application_preferences.dart';
import 'package:minimum/models/applications_group.dart';
import 'package:minimum/models/entry.dart';
import 'package:minimum/models/order.dart';
import 'package:minimum/services/applications_manager_service.dart';

part 'applications_manager_state.dart';

class ApplicationsManagerCubit extends HydratedCubit<ApplicationsManagerState> {
  final ApplicationsManagerService service;
  final PreferencesManagerCubit preferences;

  ApplicationsManagerCubit(this.service, this.preferences)
      : super(ApplicationsManagerInitial()) {
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
    final isAlreadyAdded = _getApplicationIndex(event.package) != null;
    switch (event.action) {
      case ApplicationIntentAction.packageAdded:
        final application = await service.getApplication(event.package);
        if (event.isReplacing) {
          addOrUpdateApplicationPreferences(
            application.package,
            (preferences) => preferences.copyWith(isNew: true),
          );
        } else if (!isAlreadyAdded) {
          add(application);
        }
        break;
      case ApplicationIntentAction.packageRemoved:
        if (!event.isReplacing) {
          remove(event.package);
        }
        break;
      case ApplicationIntentAction.packageChanged:
        if (!event.canLaunch) {
          remove(event.package);
        } else if (!isAlreadyAdded) {
          final application = await service.getApplication(event.package);
          add(application);
        }
        break;
    }
  }

  int? _getApplicationIndex(String package) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return null;
    final index = state._applications.indexWhere(
      (application) => application.package == package,
    );
    if (index == -1) return null;
    return index;
  }

  int? _getGroupIndex(String id) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return null;
    final index = state._groups.indexWhere(
      (group) => group.id == id,
    );
    if (index == -1) return null;
    return index;
  }

  void add(Application application) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    final applications = state._applications.add(application);
    final newState = state.copyWith(applications: applications);
    addOrUpdateApplicationPreferences(
      application.package,
      (preferences) => preferences.copyWith(isNew: true),
      newState: newState,
    );
  }

  void remove(String package) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    final index = _getApplicationIndex(package);
    if (index == null) return;
    final applications = state._applications.removeAt(index);
    final newState = state.copyWith(applications: applications);
    emit(newState);
  }

  void addOrUpdateGroup(ApplicationsGroup group) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    final index = _getGroupIndex(group.id);
    final groups = index != null
        ? state._groups.put(index, group)
        : state._groups.add(group);
    final newState = state.copyWith(groups: groups);
    emit(newState);
  }

  void removeGroup(String id) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    final index = _getGroupIndex(id);
    if (index == null) return;
    final groups = state._groups.removeAt(index);
    final newState = state.copyWith(groups: groups);
    emit(newState);
  }

  void addOrUpdateApplicationPreferences(
    String package,
    ApplicationPreferences Function(ApplicationPreferences preferences)
        callback, {
    ApplicationsManagerFetchSuccess? newState,
  }) {
    var state = newState ?? this.state;
    if (state is ApplicationsManagerFetchSuccess) {
      final preferences = state._preferences.update(
        package,
        callback,
        ifAbsent: () => callback(const ApplicationPreferences()),
      );
      emit(state.copyWith(preferences: preferences));
    }
  }

  Future<void> getInstalled() async {
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

  Future<void> uninstall(Application application) async {
    await service.uninstallApplication(application.package);
  }

  Future<void> details(Application application) async {
    await service.openApplicationDetails(application.package);
  }

  Future<void> launch(Application application) async {
    await service.launchApplication(application.package);
  }

  @override
  Future<void> close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
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
