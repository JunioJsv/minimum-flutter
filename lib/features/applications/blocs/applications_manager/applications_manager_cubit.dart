import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/models/application_event.dart';
import 'package:minimum/models/application_preferences.dart';
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

  final order = ValueNotifier(Order.asc);

  /// Internal applications preferences
  var _preferences = BuiltMap<String, ApplicationPreferences>();

  Future<void> _onApplicationEvent(ApplicationEvent event) async {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    final isAlreadyAdded = _getApplicationIndex(event.package) != null;
    switch (event.action) {
      case ApplicationIntentAction.packageAdded:
        final application = await service.getApplication(event.package);
        if (event.isReplacing) {
          setIsNew(application, true);
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

  void add(Application application) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    final applications = BuiltList<Application>(state._applications).rebuild(
      (applications) {
        applications.add(application);
        return applications;
      },
    );
    setIsNew(application, true, shouldEmit: false);
    final newState = state.copyWith(
      applications: _onSetupApplications(applications.toList()),
    );
    emit(newState);
  }

  void remove(String package) {
    final state = this.state;
    if (state is! ApplicationsManagerFetchSuccess) return;
    final index = _getApplicationIndex(package);
    if (index == null) return;
    final applications = BuiltList<Application>(state._applications).rebuild(
      (applications) => applications..removeAt(index),
    );
    final newState = state.copyWith(
      applications: _onSetupApplications(applications.toList()),
    );
    emit(newState);
  }

  List<Application> _onSetupApplications(List<Application> applications) {
    return applications.map(
      (application) {
        final preference = _preferences[application.package];
        if (preference != null) {
          return application.copyWith(preferences: preference);
        }

        return application;
      },
    ).sorted(_onCompareApplications);
  }

  List<Application> _getApplications(ApplicationsManagerFetchSuccess state) {
    return _onSetupApplications(state._applications);
  }

  int _onCompareApplications(Application application, Application other) {
    final order = this.order.value;
    final Application(
      priority: priority,
      label: label,
    ) = application;

    final Application(
      priority: otherPriority,
      label: otherLabel,
    ) = other;

    if (priority != otherPriority) return otherPriority.compareTo(priority);
    if (order == Order.desc) {
      return otherLabel.toLowerCase().compareTo(label.toLowerCase());
    }

    return label.toLowerCase().compareTo(otherLabel.toLowerCase());
  }

  Future<void> getInstalled() async {
    emit(ApplicationsManagerFetchRunning());
    try {
      final applications = await service.getInstalledApplications();
      emit(ApplicationsManagerFetchSuccess(
        applications: _onSetupApplications(applications),
        isShowingHidden: preferences.state.showHidden,
      ));
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
      emit(state.copyWith(applications: _getApplications(state)));
    }
  }

  void _onUpdateApplicationPreferences(
    Application application, {
    required ApplicationPreferences Function(ApplicationPreferences preferenses)
        update,
    ApplicationPreferences Function()? ifAbsent,
    bool shouldEmit = true,
  }) {
    final state = this.state;
    if (state is ApplicationsManagerFetchSuccess) {
      _preferences = _preferences.rebuild((preferences) {
        return preferences
          ..updateValue(
            application.package,
            update,
            ifAbsent: ifAbsent,
          );
      });
      if (shouldEmit) {
        emit(state.copyWith(applications: _getApplications(state)));
      }
    }
  }

  void setIsPinned(Application application, bool value) {
    _onUpdateApplicationPreferences(
      application,
      update: (preference) => preference.copyWith(isPinned: value),
      ifAbsent: () => ApplicationPreferences(isPinned: value),
    );
  }

  void setIsHidden(Application application, bool value) {
    _onUpdateApplicationPreferences(
      application,
      update: (preference) => preference.copyWith(isHidden: value),
      ifAbsent: () => ApplicationPreferences(isHidden: value),
    );
  }

  void setIsNew(
    Application application,
    bool value, {
    bool shouldEmit = true,
  }) {
    _onUpdateApplicationPreferences(
      application,
      update: (preference) => preference.copyWith(isNew: value),
      ifAbsent: () => ApplicationPreferences(isNew: value),
      shouldEmit: shouldEmit,
    );
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
    order.dispose();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    return super.close();
  }

  @override
  ApplicationsManagerState? fromJson(Map<String, dynamic> json) {
    final order = Order.fromJson(json['order']);
    final preferences = json['preferences'] as Map?;
    if (order != null) {
      this.order.value = order;
    }
    if (preferences != null) {
      _preferences = BuiltMap.from(preferences.map(
        (key, json) {
          return MapEntry(
            key,
            ApplicationPreferences.fromJson((json as Map).cast()),
          );
        },
      ));
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(ApplicationsManagerState state) {
    return {
      'order': order.value.toJson(),
      'preferences': _preferences.map(
        (key, preference) {
          return MapEntry(key, preference.toJson());
        },
      ).toMap()
    };
  }
}
