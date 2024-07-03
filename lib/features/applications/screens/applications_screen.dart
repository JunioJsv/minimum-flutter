import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minimum/features/applications/widgets/applications_header.dart';
import 'package:minimum/features/applications/widgets/applications_search_bar.dart';
import 'package:minimum/features/applications/widgets/grid_entry.dart';
import 'package:minimum/features/applications/widgets/list_entry.dart';
import 'package:minimum/features/applications/widgets/sliver_applications.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/main.dart';

class ApplicationsScreen extends StatelessWidget {
  static final String route = '$ApplicationsScreen';

  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ApplicationsHeader(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                ApplicationsSearchBar(
                  onChange: (query) {},
                ),
                const Divider(height: 0),
              ],
            ),
          ),
          // Todo(remove mocked apps)
          const _SliverApplications(),
        ],
      ),
    );
  }
}

class _SliverApplications extends StatelessWidget {
  const _SliverApplications();

  List<Object> getPreferencesProps(PreferencesManagerState state) {
    return [state.isGridLayoutEnabled, state.gridCrossAxisCount];
  }

  bool hasPreferencesChanges(
    PreferencesManagerState previous,
    PreferencesManagerState current,
  ) {
    return getPreferencesProps(previous) != getPreferencesProps(current);
  }

  @override
  Widget build(BuildContext context) {
    final PreferencesManagerCubit preferences = dependencies();

    return BlocBuilder<PreferencesManagerCubit, PreferencesManagerState>(
      bloc: preferences,
      buildWhen: hasPreferencesChanges,
      builder: (context, state) {
        final layout = state.isGridLayoutEnabled
            ? SliverApplicationsGridLayout(
                children: List.generate(
                  30,
                  (index) {
                    return GridEntry(
                      icon: const Placeholder(),
                      label: 'App $index',
                      onTap: () {},
                    );
                  },
                ),
                delegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: state.gridCrossAxisCount,
                ))
            : SliverApplicationsListLayout(
                children: List.generate(
                30,
                (index) {
                  return ListEntry(
                    icon: const Placeholder(),
                    label: 'App $index',
                    onTap: () {},
                  );
                },
              ));
        return SliverApplications(layout: layout);
      },
    );
  }
}
