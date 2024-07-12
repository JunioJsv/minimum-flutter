part of 'applications_manager_cubit.dart';

sealed class ApplicationsManagerState extends Equatable {
  const ApplicationsManagerState();

  @override
  List<Object?> get props => [];
}

final class ApplicationsManagerInitial extends ApplicationsManagerState {}

final class ApplicationsManagerFetchRunning extends ApplicationsManagerState {}

final class ApplicationsManagerFetchSuccess extends ApplicationsManagerState {
  final _orderBy = Entry.orderBy;
  final bool isShowingHidden;

  final Map<String, ApplicationPreferences> _preferences;
  final List<ApplicationBase> _applications;
  final List<ApplicationsGroup> groups;

  bool get isEmpty => _applications.isEmpty;

  List<Application> get applications {
    var applications = _applications.map(
      (raw) {
        final application = Application(
          label: raw.label,
          package: raw.package,
          version: raw.version,
        );
        if (_preferences.containsKey(application.package)) {
          return application.copyWith(
            preferences: _preferences[application.package],
          );
        }
        return application;
      },
    );
    if (!isShowingHidden) {
      applications = applications
          .where((application) => !application.preferences.isHidden);
    }

    return applications.toList();
  }

  /// Applications and groups
  List<Entry> get entries => [
        ...applications.where((application) {
          return !groups.any(
            (group) => group.packages.contains(application.package),
          );
        }),
        ...groups
      ]..sort();

  ApplicationsManagerFetchSuccess({
    Map<String, ApplicationPreferences> preferences = const {},
    List<ApplicationBase> applications = const [],
    this.groups = const [],
    this.isShowingHidden = false,
  })  : _preferences = preferences,
        _applications = applications;

  ApplicationsManagerFetchSuccess copyWith({
    Map<String, ApplicationPreferences>? preferences,
    List<ApplicationBase>? applications,
    List<ApplicationsGroup>? groups,
    bool? isShowingHidden,
  }) {
    return ApplicationsManagerFetchSuccess(
      preferences: preferences ?? _preferences,
      applications: applications ?? _applications,
      groups: groups ?? this.groups,
      isShowingHidden: isShowingHidden ?? this.isShowingHidden,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': _orderBy.name,
      'preferences': _preferences.map(
        (key, preferences) => MapEntry(key, preferences.toJson()),
      ),
      'groups': groups.map((group) => group.toJson()).toList(),
    };
  }

  factory ApplicationsManagerFetchSuccess.fromJson(Map<String, dynamic> json) {
    return ApplicationsManagerFetchSuccess(
      preferences: (json['preferences'] as Map).map(
        (key, json) {
          return MapEntry(
            key,
            ApplicationPreferences.fromJson((json as Map).cast()),
          );
        },
      ),
      groups: (json['groups'] as List)
          .map((json) => ApplicationsGroup.fromJson(
                (json as Map).cast(),
              ))
          .toList(),
    );
  }

  @override
  List<Object> get props => [
        _preferences,
        _applications,
        groups,
        isShowingHidden,
        _orderBy,
        isEmpty,
      ];
}

final class ApplicationsManagerFetchFailure extends ApplicationsManagerState {}
