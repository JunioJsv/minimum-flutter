part of 'preferences_manager_cubit.dart';

@JsonSerializable()
class PreferencesManagerState extends Equatable {
  final bool isGridLayoutEnabled;
  final int gridCrossAxisCount;
  @JsonKey(includeToJson: false)
  final bool showHidden;

  const PreferencesManagerState({
    this.isGridLayoutEnabled = false,
    this.gridCrossAxisCount = 4,
    this.showHidden = false,
  });

  PreferencesManagerState copyWith({
    bool? isGridLayoutEnabled,
    int? gridCrossAxisCount,
    bool? showHidden,
  }) {
    return PreferencesManagerState(
        isGridLayoutEnabled: isGridLayoutEnabled ?? this.isGridLayoutEnabled,
        gridCrossAxisCount: gridCrossAxisCount ?? this.gridCrossAxisCount,
        showHidden: showHidden ?? this.showHidden);
  }

  factory PreferencesManagerState.fromJson(Map<String, dynamic> json) {
    return _$PreferencesManagerStateFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PreferencesManagerStateToJson(this);

  @override
  List<Object> get props => [
        isGridLayoutEnabled,
        gridCrossAxisCount,
        showHidden,
      ];
}
