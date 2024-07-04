part of 'preferences_manager_cubit.dart';

@JsonSerializable()
class PreferencesManagerState extends Equatable {
  final bool isGridLayoutEnabled;
  final int gridCrossAxisCount;
  final bool isPromptingSetAsCurrentLauncher;

  const PreferencesManagerState({
    this.isGridLayoutEnabled = false,
    this.gridCrossAxisCount = 4,
    this.isPromptingSetAsCurrentLauncher = true,
  });

  PreferencesManagerState copyWith({
    bool? isGridLayoutEnabled,
    int? gridCrossAxisCount,
    bool? isPromptingSetAsCurrentLauncher,
  }) {
    return PreferencesManagerState(
      isGridLayoutEnabled: isGridLayoutEnabled ?? this.isGridLayoutEnabled,
      gridCrossAxisCount: gridCrossAxisCount ?? this.gridCrossAxisCount,
      isPromptingSetAsCurrentLauncher: isPromptingSetAsCurrentLauncher ??
          this.isPromptingSetAsCurrentLauncher,
    );
  }

  factory PreferencesManagerState.fromJson(Map<String, dynamic> json) {
    return _$PreferencesManagerStateFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PreferencesManagerStateToJson(this);

  @override
  List<Object> get props => [
        isGridLayoutEnabled,
        gridCrossAxisCount,
        isPromptingSetAsCurrentLauncher,
      ];
}
