import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/models/application.dart';
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
  }

  final List<StreamSubscription> _subscriptions = [];

  final order = ValueNotifier(Order.asc);

  /// Internal applications preferences
  var _preferences = BuiltMap<String, ApplicationPreferences>();

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

  void pin(Application application, bool value) {
    final state = this.state;
    if (state is ApplicationsManagerFetchSuccess) {
      _preferences = _preferences.rebuild((preferences) {
        return preferences
          ..updateValue(
            application.package,
            (preference) => preference.copyWith(isPinned: value),
            ifAbsent: () => ApplicationPreferences(isPinned: value),
          );
      });
      emit(state.copyWith(applications: _getApplications(state)));
    }
  }

  void hide(Application application, bool value) {
    final state = this.state;
    if (state is ApplicationsManagerFetchSuccess) {
      _preferences = _preferences.rebuild((preferences) {
        return preferences
          ..updateValue(
            application.package,
            (preference) => preference.copyWith(isHidden: value),
            ifAbsent: () => ApplicationPreferences(isHidden: value),
          );
      });
      emit(state.copyWith(applications: _getApplications(state)));
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
