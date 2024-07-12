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

  final IMap<String, ApplicationPreferences> _preferences;
  final IList<ApplicationBase> _applications;
  final IList<ApplicationsGroup> _groups;

  bool get isEmpty => _applications.isEmpty;

  late final IList<Application> applications = () {
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

    return applications.toIList();
  }();

  late final ISet<String> packages =
      applications.map((application) => application.package).toISet();

  late final IList<ApplicationsGroup> groups = () {
    return _groups
        .map((group) {
          /// Hidden or Uninstalled packages
          final hidden = group.packages.where((package) {
            return !packages.contains(package);
          }).toSet();
          if (hidden.isEmpty) return group;
          return group.copyWith(
            packages: group.packages.difference(hidden),
          );
        })
        .where((group) => group.packages.isNotEmpty)
        .toIList();
  }();

  /// Applications and groups
  late final IList<Entry> entries = IList([
    ...applications.where((application) {
      return !groups.any(
        (group) => group.packages.contains(application.package),
      );
    }),
    ...groups
  ]).sort();

  ApplicationsManagerFetchSuccess({
    IMap<String, ApplicationPreferences> preferences = const IMap.empty(),
    IList<ApplicationBase> applications = const IList.empty(),
    IList<ApplicationsGroup> groups = const IList.empty(),
    this.isShowingHidden = false,
  })  : _preferences = preferences,
        _applications = applications,
        _groups = groups;

  ApplicationsManagerFetchSuccess copyWith({
    IMap<String, ApplicationPreferences>? preferences,
    IList<ApplicationBase>? applications,
    IList<ApplicationsGroup>? groups,
    bool? isShowingHidden,
  }) {
    return ApplicationsManagerFetchSuccess(
      preferences: preferences ?? _preferences,
      applications: applications ?? _applications,
      groups: groups ?? _groups,
      isShowingHidden: isShowingHidden ?? this.isShowingHidden,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': Entry.orderBy.toJson(),
      'preferences': _preferences.unlock.map((key, preferences) {
        return MapEntry(key, preferences.toJson());
      }),
      'groups': _groups.map((group) => group.toJson()).toList(),
    };
  }

  factory ApplicationsManagerFetchSuccess.fromJson(Map<String, dynamic> json) {
    return ApplicationsManagerFetchSuccess(
      preferences: (json['preferences'] as Map).map(
        (key, json) {
          return MapEntry<String, ApplicationPreferences>(
            key,
            ApplicationPreferences.fromJson((json as Map).cast()),
          );
        },
      ).toIMap(),
      groups: (json['groups'] as List).map((json) {
        return ApplicationsGroup.fromJson((json as Map).cast());
      }).toIList(),
    );
  }

  @override
  List<Object> get props => [
        _preferences,
        _applications,
        _groups,
        isShowingHidden,
        applications,
        groups,
        entries,
        packages,
      ];
}

final class ApplicationsManagerFetchFailure extends ApplicationsManagerState {}
