import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minimum/models/icon_pack.dart';
import 'package:minimum/services/applications_manager_service.dart';

part 'preferences_manager_cubit.g.dart';
part 'preferences_manager_state.dart';

class PreferencesManagerCubit extends HydratedCubit<PreferencesManagerState> {
  final ApplicationsManagerService service;

  PreferencesManagerCubit(this.service)
      : super(const PreferencesManagerState());

  Future<void> update(
    PreferencesManagerState Function(
      PreferencesManagerState preferences,
    ) callback,
  ) async {
    final previousState = state;
    var newState = callback(previousState);
    if (previousState.iconPack != newState.iconPack) {
      final iconPack = newState.iconPack;
      final isIconPackApplied = await _onApplyIconPack(iconPack?.package);
      if (!isIconPackApplied) {
        newState = newState.copyWith(iconPack: () => null);
      }
    }
    emit(newState);
  }

  Future<bool> _onApplyIconPack(String? package) async {
    final isIconPackApplied =
        await service.setIconPack(package).catchError((e) => false);
    return isIconPackApplied;
  }

  @override
  PreferencesManagerState? fromJson(Map<String, dynamic> json) {
    try {
      final state = PreferencesManagerState.fromJson(json);
      var iconPack = state.iconPack;
      if (iconPack != null) {
        _onApplyIconPack(iconPack.package).then((isIconPackApplied) {
          if (!isIconPackApplied) {
            emit(state.copyWith(iconPack: () => null));
          }
        });
      }
      return state;
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(PreferencesManagerState state) {
    return state.toJson();
  }
}
