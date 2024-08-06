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

  ApplicationPreferences getApplicationPreferences(String package) {
    return _preferences[package] ?? const ApplicationPreferences();
  }

  int? getApplicationIndex(String package) {
    final index = _applications.indexWhere(
      (application) => application.package == package,
    );
    if (index == -1) return null;
    return index;
  }

  bool hasApplication(String package) => getApplicationIndex(package) != null;

  int? getGroupIndex(String id) {
    final index = _groups.indexWhere(
      (group) => group.id == id,
    );
    if (index == -1) return null;
    return index;
  }

  ApplicationsManagerFetchSuccessBuilder get builder =>
      ApplicationsManagerFetchSuccessBuilder(this);

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

class ApplicationsManagerFetchSuccessBuilder {
  ApplicationsManagerFetchSuccess _state;

  ApplicationsManagerFetchSuccessBuilder([
    ApplicationsManagerFetchSuccess? state,
  ]) : _state = state ?? ApplicationsManagerFetchSuccess();

  ApplicationsManagerFetchSuccess build() => _state;

  ApplicationsManagerFetchSuccessBuilder addApplication(
    Application application,
  ) {
    if (!_state.hasApplication(application.package)) {
      final applications = _state._applications.add(application);
      _state = _state.copyWith(applications: applications);
      addOrUpdateApplicationPreferences(
        application.package,
        (preferences) => preferences.copyWith(isNew: true),
      );
    }
    return this;
  }

  ApplicationsManagerFetchSuccessBuilder addOrUpdateApplicationPreferences(
    String package,
    ApplicationPreferences Function(
      ApplicationPreferences preferences,
    ) callback,
  ) {
    final preferences = _state._preferences.update(
      package,
      callback,
      ifAbsent: () => callback(const ApplicationPreferences()),
    );
    _state = _state.copyWith(preferences: preferences);
    return this;
  }

  ApplicationsManagerFetchSuccessBuilder removeApplication(String package) {
    final index = _state.getApplicationIndex(package);
    if (index != null) {
      final applications = _state._applications.removeAt(index);
      _state = _state.copyWith(applications: applications);
    }
    return this;
  }

  ApplicationsManagerFetchSuccessBuilder addOrUpdateGroup(
    ApplicationsGroup group,
  ) {
    final index = _state.getGroupIndex(group.id);
    final groups = index != null
        ? _state._groups.put(index, group)
        : _state._groups.add(group);
    _state = _state.copyWith(groups: groups);
    return this;
  }

  ApplicationsManagerFetchSuccessBuilder removeGroup(String id) {
    final index = _state.getGroupIndex(id);
    if (index != null) {
      final groups = _state._groups.removeAt(index);
      _state = _state.copyWith(groups: groups);
    }
    return this;
  }
}

final class ApplicationsManagerFetchFailure extends ApplicationsManagerState {}
