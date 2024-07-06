import 'package:flutter/material.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/features/applications/widgets/application_avatar.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';
import 'package:minimum/features/applications/widgets/list_entry.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/widgets/warning_container.dart';

class ApplicationsSearchBar extends StatefulWidget {
  final List<Application> applications;

  const ApplicationsSearchBar({super.key, required this.applications});

  @override
  State<ApplicationsSearchBar> createState() => _ApplicationsSearchBarState();
}

class _ApplicationsSearchBarState extends State<ApplicationsSearchBar>
    implements RouteAware {
  final focusNode = FocusNode();
  final controller = SearchController();

  late final ApplicationsScreenState screen = dependencies();

  @override
  void initState() {
    screen.scroll.addListener(_onApplicationsScrollControllerListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      observer.subscribe(this, ModalRoute.of(context)!);
    });
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    screen.scroll.removeListener(_onApplicationsScrollControllerListener);
    observer.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {}

  @override
  void didPopNext() {}

  @override
  void didPush() {}

  @override
  void didPushNext() {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
  }

  void _onApplicationsScrollControllerListener() {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
  }

  @override
  void didUpdateWidget(covariant ApplicationsSearchBar oldWidget) {
    if (widget.applications != oldWidget.applications) {
      if (controller.isOpen) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            controller.closeView('');
            focusNode.unfocus();
          },
        );
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    final applications = widget.applications;
    final theme = Theme.of(context);
    return SearchAnchor(
      searchController: controller,
      dividerColor: theme.colorScheme.outlineVariant,
      viewHintText: translation.search,
      builder: (context, controller) {
        return SearchBar(
          focusNode: focusNode,
          controller: controller,
          leading: const Icon(Icons.search),
          hintText: translation.search,
          keyboardType: TextInputType.none,
          onTap: () {
            controller.openView();
          },
          onChanged: (_) {
            controller.openView();
          },
        );
      },
      viewBuilder: (suggestions) {
        final query = controller.text;
        if (query.isEmpty) {
          return WarningContainer(
            icon: Icons.search,
            color: theme.colorScheme.onSurface,
            message: translation.typeNameToSearch,
          );
        }

        if (query.isNotEmpty && suggestions.isEmpty) {
          return WarningContainer(
            icon: Icons.search_off,
            color: theme.colorScheme.onSurface,
            message: translation.noResultsFor(query: query),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) => suggestions.elementAt(index),
          separatorBuilder: (context, index) => const Divider(height: 0),
          itemCount: suggestions.length,
        );
      },
      suggestionsBuilder: (context, controller) {
        if (controller.text.isEmpty) return [];
        return applications.where(
          (application) {
            return application.label
                .toLowerCase()
                .contains(controller.text.toLowerCase());
          },
        ).map(
          (application) {
            return ListEntry(
              key: ValueKey(application.package),
              arguments: EntryWidgetArguments(
                icon: ApplicationAvatar(application: application),
                label: application.label,
                onTap: () async {
                  await screen.onApplicationTap(context, application);
                  controller.closeView('');
                  focusNode.unfocus();
                },
                onLongTap: () async {
                  await screen.onApplicationLongTap(context, application);
                },
              ),
            );
          },
        );
      },
    );
  }
}
