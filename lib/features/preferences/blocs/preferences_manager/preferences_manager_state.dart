part of 'preferences_manager_cubit.dart';

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

  @override
  List<Object> get props => [isGridLayoutEnabled, gridCrossAxisCount];
}
