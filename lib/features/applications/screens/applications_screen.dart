import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minimum/features/applications/blocs/applications_manager/applications_manager_cubit.dart';
import 'package:minimum/features/applications/widgets/application_actions_bottom_sheet.dart';
import 'package:minimum/features/applications/widgets/application_avatar.dart';
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
import 'package:minimum/services/local_authentication_service.dart';
import 'package:minimum/widgets/confirmation_dialog.dart';

class ApplicationsScreen extends StatefulWidget {
  static final String route = '$ApplicationsScreen';

  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => ApplicationsScreenState();
}

class ApplicationsScreenState extends State<ApplicationsScreen> {
  final scroll = ScrollController();
  final ApplicationsManagerCubit applications = dependencies();
  final LocalAuthenticationService auth = dependencies();
  late final translation = context.translations;

  @override
  void initState() {
    super.initState();
    dependencies.registerSingleton<ApplicationsScreenState>(this);
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
    dependencies.unregister<ApplicationsScreenState>();
    scroll.dispose();
  }

  Future<void> onScrollTo(double offset) {
    return scroll.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
    );
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

  Future<void> onApplicationTap(
    BuildContext context,
    Application application,
  ) async {
    await applications.launch(application);
    if (application.preferences.isNew) {
      applications.setIsNew(application, false);
    }
  }

  Future<void> onApplicationLongTap(
    BuildContext context,
    Application application,
  ) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ApplicationActionsBottomSheet(application: application);
      },
    );
  }

  void onToggleApplicationPin(BuildContext context, Application application) {
    final isPinned = !application.preferences.isPinned;
    applications.setIsPinned(application, isPinned);
    if (isPinned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onScrollTo(0);
      });
    }
  }

  Future<void> onToggleApplicationHide(
    BuildContext context,
    Application application,
  ) async {
    final isHidden = !application.preferences.isHidden;
    final isDeviceSecure = await auth.isDeviceSecure();
    if (!isDeviceSecure && isHidden) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => ConfirmationDialog(
            title: translation.lockscreenRequired,
            message: translation.setupLockscreen(
              to: translation.hideApplications.toLowerCase(),
            ),
            confirm: translation.understood,
          ),
        );
      });
      return;
    }

    applications.setIsHidden(application, isHidden);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        onScrollTo(0);
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
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ApplicationsShortcuts(),
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
    final applications = state.applications;
    final arguments = applications.mapIndexed(
      (index, application) {
        return EntryWidgetArguments(
          icon: ApplicationAvatar(application: application),
          label: application.label,
          onTap: () => screen.onApplicationTap(context, application),
          onLongTap: () => screen.onApplicationLongTap(context, application),
        );
      },
    );

    return BlocBuilder<PreferencesManagerCubit, PreferencesManagerState>(
      bloc: preferences,
      buildWhen: hasPreferencesChanges,
      builder: (context, preferences) {
        final layout = preferences.isGridLayoutEnabled
            ? SliverApplicationsGridLayout(
                children: arguments.mapIndexed(
                  (index, arguments) {
                    final package = applications[index].package;
                    return GridEntry(
                      key: GlobalObjectKey(package),
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
                children: arguments.mapIndexed(
                (index, arguments) {
                  final package = applications[index].package;
                  return ListEntry(
                    key: GlobalObjectKey(package),
                    arguments: arguments,
                  );
                },
              ).toList());
        return SliverApplications(layout: layout);
      },
    );
  }
}
