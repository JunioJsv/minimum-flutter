import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart'
    hide Entry;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minimum/features/applications/blocs/applications_manager/applications_manager_cubit.dart';
import 'package:minimum/features/applications/utils/applications_actions.dart';
import 'package:minimum/features/applications/utils/applications_groups_actions.dart';
import 'package:minimum/features/applications/widgets/application_avatar.dart';
import 'package:minimum/features/applications/widgets/applications_group_avatar.dart';
import 'package:minimum/features/applications/widgets/applications_header.dart';
import 'package:minimum/features/applications/widgets/applications_search_bar.dart';
import 'package:minimum/features/applications/widgets/applications_shortcuts.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';
import 'package:minimum/features/applications/widgets/grid_entry.dart';
import 'package:minimum/features/applications/widgets/list_entry.dart';
import 'package:minimum/features/applications/widgets/sliver_applications.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/models/applications_group.dart';
import 'package:minimum/models/entry.dart';
import 'package:minimum/widgets/confirmation_dialog.dart';

class ApplicationsScreen extends StatefulWidget {
  static final String route = '$ApplicationsScreen';

  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final _controller = ScrollController();
  final ApplicationsManagerCubit applications = dependencies();
  late final translation = context.translations;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isAlreadyCurrentLauncher =
          await applications.service.isAlreadyCurrentLauncher();

      if (!isAlreadyCurrentLauncher) {
        if (mounted) {
          _showSetAsCurrentLauncherDialog(context);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _showSetAsCurrentLauncherDialog(BuildContext context) async {
    final confirmation = await showDialog<bool?>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: translation.setHasDefaultLauncher,
        message: translation.askSetHasDefaultLauncher,
        confirm: translation.yes,
        decline: translation.no,
      ),
    );
    if (confirmation == true) {
      await applications.service.openCurrentLauncherSystemSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget loading() {
      return const Center(child: CircularProgressIndicator());
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _controller.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      },
      child: Scaffold(
        appBar: const ApplicationsHeader(),
        body: BlocBuilder<ApplicationsManagerCubit, ApplicationsManagerState>(
          bloc: applications,
          builder: (context, state) {
            if (state is! ApplicationsManagerFetchSuccess) {
              return loading();
            }

            if (state.isEmpty) return loading();

            return CustomScrollView(
              controller: _controller,
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
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ApplicationsShortcuts(),
                  ),
                ),
                SliverEntries(entries: state.entries),
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

class SliverEntries extends StatefulWidget {
  final IList<Entry> entries;

  const SliverEntries({super.key, required this.entries});

  @override
  State<SliverEntries> createState() => _SliverEntriesState();
}

class _SliverEntriesState extends State<SliverEntries>
    with ApplicationsActionsListener {
  final applicationsActions = dependencies<ApplicationsActions>();
  final applicationsGroupsActions = dependencies<ApplicationsGroupsActions>();
  final preferences = dependencies<PreferencesManagerCubit>();
  late var packages = getPackages();

  @override
  void initState() {
    super.initState();
    applicationsActions.addListener(this);
  }

  @override
  void dispose() {
    applicationsActions.removeListener(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(SliverEntries oldWidget) {
    packages = getPackages();
    super.didUpdateWidget(oldWidget);
  }

  IList<String> getPackages() {
    return widget.entries
        .whereType<Application>()
        .map((application) => application.package)
        .toIList();
  }

  Future<void> onScrollTo(double offset) {
    return Scrollable.of(context).position.animateTo(
          offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
  }

  @override
  void didToggleApplicationPin(Application application) {
    final isPinned = application.preferences.isPinned;
    if (isPinned && packages.anyIs(application.package)) {
      onScrollTo(0);
    }
  }

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
    final entries = widget.entries.map(
      (entry) {
        if (entry is Application) {
          return EntryWidgetArguments(
            id: entry.package,
            icon: ApplicationAvatar(application: entry),
            label: entry.label,
            onTap: () => applicationsActions.tap(entry),
            onLongTap: () => applicationsActions.longTap(context, entry),
          );
        }
        if (entry is ApplicationsGroup) {
          return EntryWidgetArguments(
            id: entry.id,
            icon: ApplicationsGroupAvatar(group: entry),
            label: entry.label,
            onTap: () => applicationsGroupsActions.tap(context, entry),
            onLongTap: () {},
          );
        }

        throw UnimplementedError();
      },
    ).toList();

    return BlocConsumer<PreferencesManagerCubit, PreferencesManagerState>(
      bloc: preferences,
      listener: (context, preferences) {
        if (preferences.showHidden) {
          onScrollTo(0);
        }
      },
      listenWhen: (previous, current) =>
          previous.showHidden != current.showHidden,
      buildWhen: hasPreferencesChanges,
      builder: (context, preferences) {
        final layout = preferences.isGridLayoutEnabled
            ? SliverApplicationsGridLayout(
                children: entries.mapIndexed(
                  (index, arguments) {
                    final package = arguments.id!;
                    return GridEntry(
                      key: ValueKey(package),
                      arguments: arguments,
                    );
                  },
                ).toList(),
                delegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: preferences.gridCrossAxisCount,
                  childAspectRatio: 3 / 4,
                ),
              )
            : SliverApplicationsListLayout(
                children: entries.mapIndexed(
                (index, arguments) {
                  final package = arguments.id!;
                  return ListEntry(
                    key: ValueKey(package),
                    arguments: arguments,
                  );
                },
              ).toList());
        return SliverApplications(layout: layout);
      },
    );
  }
}
