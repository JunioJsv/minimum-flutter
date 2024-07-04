part of 'applications_manager_cubit.dart';

sealed class ApplicationsManagerState extends Equatable {
  const ApplicationsManagerState();

  @override
  List<Object> get props => [];
}

final class ApplicationsManagerInitial extends ApplicationsManagerState {}

final class ApplicationsManagerFetchRunning extends ApplicationsManagerState {}

final class ApplicationsManagerFetchSuccess extends ApplicationsManagerState {
  final List<Application> applications;

  const ApplicationsManagerFetchSuccess({required this.applications});

  @override
  List<Object> get props => [applications];
}

final class ApplicationsManagerFetchFailure extends ApplicationsManagerState {}
