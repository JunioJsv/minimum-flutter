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

  List<Application> get applications => !isShowingHidden
      ? _applications
          .where((application) => !application.preferences.isHidden)
          .toList()
      : _applications;

  const ApplicationsManagerFetchSuccess({
    required List<Application> applications,
    required this.isShowingHidden,
  }) : _applications = applications;

  ApplicationsManagerFetchSuccess copyWith({
    List<Application>? applications,
    bool? isShowingHidden,
  }) {
    return ApplicationsManagerFetchSuccess(
      applications: applications ?? _applications,
      isShowingHidden: isShowingHidden ?? this.isShowingHidden,
    );
  }

  @override
  List<Object> get props => [_applications, isShowingHidden];
}

final class ApplicationsManagerFetchFailure extends ApplicationsManagerState {}
