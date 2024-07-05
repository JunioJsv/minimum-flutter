import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/models/application_preferences.dart';
import 'package:minimum/services/applications_manager_service.dart';

part 'applications_manager_state.dart';

class ApplicationsManagerCubit extends HydratedCubit<ApplicationsManagerState> {
  final ApplicationsManagerService service;

  ApplicationsManagerCubit(this.service) : super(ApplicationsManagerInitial());

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
    ).sorted();
  }

  Future<void> getInstalled() async {
    emit(ApplicationsManagerFetchRunning());
    try {
      final applications = await service.getInstalledApplications();
      emit(ApplicationsManagerFetchSuccess(
        applications: _onSetupApplications(applications),
      ));
    } catch (_, s) {
      emit(ApplicationsManagerFetchFailure());
      if (kDebugMode) {
        print(s);
      }
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
      emit(ApplicationsManagerFetchSuccess(
        applications: _onSetupApplications(state.applications),
      ));
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
  ApplicationsManagerState? fromJson(Map<String, dynamic> json) {
    final preferences = json['preferences'] as Map?;
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
      'preferences': _preferences.map(
        (key, preference) {
          return MapEntry(key, preference.toJson());
        },
      ).toMap()
    };
  }
}
