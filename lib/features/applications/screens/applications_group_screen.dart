import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minimum/features/applications/blocs/applications_manager/applications_manager_cubit.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/features/applications/screens/create_applications_group_screen.dart';
import 'package:minimum/features/applications/utils/applications_groups_actions.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/models/applications_group.dart';
import 'package:minimum/routes.dart';
import 'package:minimum/widgets/confirmation_dialog.dart';

class ApplicationsGroupArgumentsScreen {
  final String id;

  ApplicationsGroupArgumentsScreen({required this.id});

  static ApplicationsGroupArgumentsScreen of(BuildContext context) {
    return ModalRoute.of(context)!.arguments();
  }
}

typedef _GroupState = ({
  ApplicationsGroup group,
  IList<Application> applications
});

class ApplicationsGroupScreen extends StatelessWidget {
  static final route = '$ApplicationsGroupScreen';

  const ApplicationsGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ApplicationsGroupArgumentsScreen.of(context);
    final applications = dependencies<ApplicationsManagerCubit>();
    final applicationsGroupsActions = dependencies<ApplicationsGroupsActions>();
    final translation = context.translations;
    final content = BlocSelector<ApplicationsManagerCubit,
        ApplicationsManagerState, _GroupState?>(
      bloc: applications,
      selector: (state) {
        if (state is! ApplicationsManagerFetchSuccess) return null;

        final group = state.groups.firstWhereOrNull(
          (group) => group.id == arguments.id,
        );
        if (group == null) return null;
        final applications = state.applications.where(
          (application) => group.packages.contains(application.package),
        );

        return (group: group, applications: IList(applications).sort());
      },
      builder: (context, state) {
        if (state == null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => Navigator.pop(context),
          );
          return const SizedBox.shrink();
        }
        final group = state.group;
        final description = group.description;

        return CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      group.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        CreateApplicationsGroupScreen.route,
                        arguments: CreateApplicationsGroupScreenArguments(
                          initial: group,
                          onConfirm: (group) {
                            applicationsGroupsActions.addOrUpdate(group);
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.dashboard_customize_outlined),
                  ),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        return ConfirmationDialog(
                          title: translation.wantDeleteGroup,
                          message: translation.groupDeleteHint(
                            count: state.applications.length,
                          ),
                          confirm: translation.confirm,
                          decline: translation.cancel,
                        );
                      },
                    ).then((confirmation) {
                      if (confirmation == true) {
                        applicationsGroupsActions.remove(group);
                      }
                    }),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
            if (description != null && description.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8)
                      .add(const EdgeInsets.only(bottom: 16)),
                  child: Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(description),
                    ),
                  ),
                ),
              ),
            SliverEntries(entries: state.applications),
            const SliverToBoxAdapter(
              child: SizedBox(height: kToolbarHeight),
            )
          ],
        );
      },
    );

    return Scaffold(
      body: content,
    );
  }
}
