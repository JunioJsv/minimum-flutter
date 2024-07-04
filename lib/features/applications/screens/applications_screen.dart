import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minimum/features/applications/blocs/applications_manager/applications_manager_cubit.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';
import 'package:minimum/features/applications/widgets/applications_header.dart';
import 'package:minimum/features/applications/widgets/applications_search_bar.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';
import 'package:minimum/features/applications/widgets/grid_entry.dart';
import 'package:minimum/features/applications/widgets/list_entry.dart';
import 'package:minimum/features/applications/widgets/sliver_applications.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';

class ApplicationsScreen extends StatefulWidget {
  static final String route = '$ApplicationsScreen';

  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => ApplicationsScreenState();
}

class ApplicationsScreenState extends State<ApplicationsScreen> {
  final scroll = ScrollController();
  final ApplicationsManagerCubit applications = dependencies();

  @override
  void dispose() {
    super.dispose();
    scroll.dispose();
  }

  Future<void> onApplicationTap(Application application) async {
    return applications.service.launchApplication(application.package);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        scroll.animateTo(
          0,
          duration: kThemeAnimationDuration,
          curve: Curves.linear,
        );
      },
      child: Scaffold(
        appBar: const ApplicationsHeader(),
        body: BlocBuilder<ApplicationsManagerCubit, ApplicationsManagerState>(
          bloc: applications,
          builder: (context, state) {
            if (state is! ApplicationsManagerFetchSuccess) {
              return const Center(child: CircularProgressIndicator());
            }
            return CustomScrollView(
              controller: scroll,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                            .add(const EdgeInsets.only(top: 8)),
                    child: ApplicationsSearchBar(
                      applications: state.applications,
                    ),
                  ),
                ),
                _SliverApplications(state),
                const SliverToBoxAdapter(
                  child: SizedBox(height: kToolbarHeight),
                )
              ],
            );
          },
        ),
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

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorStateOfType<ApplicationsScreenState>()!;
    final PreferencesManagerCubit preferences = dependencies();
    final applications = state.applications.mapIndexed(
      (index, application) {
        return EntryWidgetArguments(
          icon: ApplicationIcon(
            key: ValueKey('${application.package}#icon'),
            package: application.package,
          ),
          label: application.label,
          onTap: () => screen.onApplicationTap(application),
        );
      },
    );

    return BlocBuilder<PreferencesManagerCubit, PreferencesManagerState>(
      bloc: preferences,
      buildWhen: hasPreferencesChanges,
      builder: (context, state) {
        final layout = state.isGridLayoutEnabled
            ? SliverApplicationsGridLayout(
                children: applications.mapIndexed(
                  (index, arguments) {
                    return GridEntry(
                      key: ValueKey(index),
                      arguments: arguments,
                    );
                  },
                ).toList(),
                delegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: state.gridCrossAxisCount,
                  childAspectRatio: 3 / 4,
                ),
              )
            : SliverApplicationsListLayout(
                children: applications.mapIndexed(
                (index, arguments) {
                  return ListEntry(
                    key: ValueKey(index),
                    arguments: arguments,
                  );
                },
              ).toList());
        return SliverApplications(layout: layout);
      },
    );
  }
}
