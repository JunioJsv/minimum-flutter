part of 'preferences_manager_cubit.dart';

@JsonSerializable()
class PreferencesManagerState extends Equatable {
  final bool isGridLayoutEnabled;
  final int gridCrossAxisCount;

  const PreferencesManagerState({
    this.isGridLayoutEnabled = false,
    this.gridCrossAxisCount = 4,
  });

  PreferencesManagerState copyWith({
    bool? isGridLayoutEnabled,
    int? gridCrossAxisCount,
  }) {
    return PreferencesManagerState(
      isGridLayoutEnabled: isGridLayoutEnabled ?? this.isGridLayoutEnabled,
      gridCrossAxisCount: gridCrossAxisCount ?? this.gridCrossAxisCount,
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
      ];
}
