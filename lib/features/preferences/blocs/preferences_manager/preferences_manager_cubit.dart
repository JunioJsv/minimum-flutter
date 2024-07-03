import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

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
    // TODO: implement fromJson
    return null;
  }

  @override
  Map<String, dynamic>? toJson(PreferencesManagerState state) {
    // TODO: implement toJson
    return null;
  }
}
