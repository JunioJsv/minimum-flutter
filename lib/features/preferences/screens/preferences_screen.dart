import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/features/preferences/widgets/category_text.dart';
import 'package:minimum/features/preferences/widgets/slider_list_tile.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';

class PreferencesScreen extends StatelessWidget {
  static final String route = '$PreferencesScreen';

  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    final PreferencesManagerCubit preferences = dependencies();
    return Scaffold(
      appBar: AppBar(
        title: Text(translation.preferences),
        leading: const BackButton(),
      ),
      body: ListView(
        children: [
          CategoryText(text: translation.appearance),
          BlocSelector<PreferencesManagerCubit, PreferencesManagerState, bool>(
            bloc: preferences,
            selector: (state) {
              return state.isGridLayoutEnabled;
            },
            builder: (context, value) {
              return SwitchListTile(
                title: Text(translation.gridView),
                subtitle: Text(translation.enableGridView),
                value: value,
                onChanged: (value) => preferences.update((preferences) {
                  return preferences.copyWith(isGridLayoutEnabled: value);
                }),
              );
            },
          ),
          BlocSelector<PreferencesManagerCubit, PreferencesManagerState,
              ({bool isEnabled, int count})>(
            bloc: preferences,
            selector: (state) {
              return (
                isEnabled: state.isGridLayoutEnabled,
                count: state.gridCrossAxisCount,
              );
            },
            builder: (context, preference) {
              return SliderListTile(
                min: 2,
                max: 5,
                isEnabled: preference.isEnabled,
                value: preference.count,
                onChange: (int value) => preferences.update((preferences) {
                  return preferences.copyWith(gridCrossAxisCount: value);
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
