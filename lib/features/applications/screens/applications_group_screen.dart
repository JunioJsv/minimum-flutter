import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minimum/features/applications/blocs/applications_manager/applications_manager_cubit.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/models/applications_group.dart';
import 'package:minimum/routes.dart';

class ApplicationsGroupArgumentsScreen {
  final String id;

  ApplicationsGroupArgumentsScreen({required this.id});

  static ApplicationsGroupArgumentsScreen of(BuildContext context) {
    return ModalRoute.of(context)!.arguments();
  }
}

typedef _GroupState = ({
  ApplicationsGroup group,
  List<Application> applications
});

class ApplicationsGroupScreen extends StatelessWidget {
  static final route = '$ApplicationsGroupScreen';

  const ApplicationsGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ApplicationsGroupArgumentsScreen.of(context);
    final applications = dependencies<ApplicationsManagerCubit>();
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

        return (group: group, applications: applications.toList()..sort());
      },
      builder: (context, state) {
        if (state == null) return const SizedBox.shrink();
        final group = state.group;

        return CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(group.label),
            ),
            SliverEntries(entries: state.applications),
          ],
        );
      },
    );

    return Scaffold(
      body: content,
    );
  }
}
