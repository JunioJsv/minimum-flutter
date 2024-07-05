import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/services/applications_manager_service.dart';

part 'applications_manager_state.dart';

class ApplicationsManagerCubit extends Cubit<ApplicationsManagerState> {
  final ApplicationsManagerService service;

  ApplicationsManagerCubit(this.service) : super(ApplicationsManagerInitial());

  Future<void> getInstalled() async {
    emit(ApplicationsManagerFetchRunning());
    try {
      final applications = await service.getInstalledApplications();
      emit(ApplicationsManagerFetchSuccess(
        applications: applications.sorted(),
      ));
    } catch (_, s) {
      emit(ApplicationsManagerFetchFailure());
      if (kDebugMode) {
        print(s);
      }
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
}
