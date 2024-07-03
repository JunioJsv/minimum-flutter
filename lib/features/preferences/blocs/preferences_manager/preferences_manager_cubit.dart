import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preferences_manager_cubit.g.dart';

part 'preferences_manager_state.dart';

class PreferencesManagerCubit extends HydratedCubit<PreferencesManagerState> {
  PreferencesManagerCubit() : super(const PreferencesManagerState());

  void update(
    PreferencesManagerState Function(
      PreferencesManagerState preferences,
    ) callback,
  ) {
    emit(callback(state));
  }

  @override
  PreferencesManagerState? fromJson(Map<String, dynamic> json) {
    try {
      return PreferencesManagerState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(PreferencesManagerState state) {
    return state.toJson();
  }
}
