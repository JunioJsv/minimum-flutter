import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minimum/features/applications/blocs/applications_manager/applications_manager_cubit.dart';
import 'package:minimum/features/applications/widgets/applications_header.dart';
import 'package:minimum/features/applications/widgets/applications_search_bar.dart';
import 'package:minimum/features/applications/widgets/grid_entry.dart';
import 'package:minimum/features/applications/widgets/list_entry.dart';
import 'package:minimum/features/applications/widgets/sliver_applications.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/services/applications_manager_service.dart';

class ApplicationsScreen extends StatelessWidget {
  static final String route = '$ApplicationsScreen';

  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ApplicationsManagerCubit applications = dependencies();

    return Scaffold(
      appBar: const ApplicationsHeader(),
      body: BlocBuilder<ApplicationsManagerCubit, ApplicationsManagerState>(
        bloc: applications,
        builder: (context, state) {
          if (state is! ApplicationsManagerFetchSuccess) {
            return const Center(child: CircularProgressIndicator());
          }
          return CustomScrollView(
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
              _SliverApplications(state),
            ],
          );
        },
      ),
    );
  }
}

class _SliverApplications extends StatelessWidget {
  final ApplicationsManagerFetchSuccess state;

  const _SliverApplications(this.state);

  List<Object> getPreferencesProps(PreferencesManagerState state) {
    return [state.isGridLayoutEnabled, state.gridCrossAxisCount];
  }

  bool hasPreferencesChanges(
    PreferencesManagerState previous,
    PreferencesManagerState current,
  ) {
    return getPreferencesProps(previous) != getPreferencesProps(current);
  }

  void onTap(Application application) {
    dependencies<ApplicationsManagerService>()
        .launchApplication(application.package);
  }

  @override
  Widget build(BuildContext context) {
    final PreferencesManagerCubit preferences = dependencies();
    final applications = state.applications;

    return BlocBuilder<PreferencesManagerCubit, PreferencesManagerState>(
      bloc: preferences,
      buildWhen: hasPreferencesChanges,
      builder: (context, state) {
        final layout = state.isGridLayoutEnabled
            ? SliverApplicationsGridLayout(
                children: applications.map(
                  (application) {
                    return GridEntry(
                      icon: const Placeholder(),
                      label: application.label,
                      onTap: () => onTap(application),
                    );
                  },
                ).toList(),
                delegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: state.gridCrossAxisCount,
                ))
            : SliverApplicationsListLayout(
                children: applications.map(
                (application) {
                  return ListEntry(
                    icon: const Placeholder(),
                    label: application.label,
                    onTap: () => onTap(application),
                  );
                },
              ).toList());
        return SliverApplications(layout: layout);
      },
    );
  }
}
