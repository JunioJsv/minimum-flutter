part of 'applications_manager_cubit.dart';

sealed class ApplicationsManagerState extends Equatable {
  const ApplicationsManagerState();

  @override
  List<Object?> get props => [];
}

final class ApplicationsManagerInitial extends ApplicationsManagerState {}

final class ApplicationsManagerFetchRunning extends ApplicationsManagerState {}

final class ApplicationsManagerFetchSuccess extends ApplicationsManagerState {
  final bool isShowingHidden;
  final List<Application> _applications;
  final List<ApplicationsGroup> groups;

  List<Application> get applications => !isShowingHidden
      ? _applications
          .where((application) => !application.preferences.isHidden)
          .toList()
      : _applications;

  /// Applications and groups
  List<Entry> get entries => [
        ...applications.where((application) {
          return !groups.any(
            (group) => group.packages.contains(application.package),
          );
        }),
        ...groups
      ]..sort();

  const ApplicationsManagerFetchSuccess({
    required List<Application> applications,
    required this.groups,
    required this.isShowingHidden,
  }) : _applications = applications;

  ApplicationsManagerFetchSuccess copyWith({
    List<Application>? applications,
    List<ApplicationsGroup>? groups,
    bool? isShowingHidden,
  }) {
    return ApplicationsManagerFetchSuccess(
      applications: applications ?? _applications,
      groups: groups ?? this.groups,
      isShowingHidden: isShowingHidden ?? this.isShowingHidden,
    );
  }

  @override
  List<Object> get props => [_applications, groups, isShowingHidden];
}

final class ApplicationsManagerFetchFailure extends ApplicationsManagerState {}
