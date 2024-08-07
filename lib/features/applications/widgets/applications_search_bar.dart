import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:minimum/features/applications/utils/applications_actions.dart';
import 'package:minimum/features/applications/widgets/application_avatar.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';
import 'package:minimum/features/applications/widgets/list_entry.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/utils/ancestral_scrollable_mixin.dart';
import 'package:minimum/widgets/warning_container.dart';

class ApplicationsSearchBar extends StatefulWidget {
  final IList<Application> applications;

  const ApplicationsSearchBar({super.key, required this.applications});

  @override
  State<ApplicationsSearchBar> createState() => _ApplicationsSearchBarState();
}

class _ApplicationsSearchBarState extends State<ApplicationsSearchBar>
    with AncestralScrollableMixin
    implements RouteAware {
  final focusNode = FocusNode();
  final controller = SearchController();
  late final applicationsActions = dependencies<ApplicationsActions>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      observer.subscribe(this, ModalRoute.of(context)!);
    });
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
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

  @override
  void didChangeAncestralScrollablePosition() {
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
          return FractionallySizedBox(
            heightFactor: .7,
            alignment: Alignment.topCenter,
            child: WarningContainer(
              icon: Icons.search,
              color: theme.colorScheme.onSurface,
              message: translation.typeNameToSearch,
            ),
          );
        }

        if (query.isNotEmpty && suggestions.isEmpty) {
          return FractionallySizedBox(
            heightFactor: .7,
            alignment: Alignment.topCenter,
            child: WarningContainer(
              icon: Icons.search_off,
              color: theme.colorScheme.onSurface,
              message: translation.noResultsFor(query: query),
            ),
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
                onTap: () {
                  applicationsActions.tap(application);
                  controller.closeView('');
                  focusNode.unfocus();
                },
                onLongTap: () {
                  applicationsActions.longTap(context, application);
                },
              ),
            );
          },
        );
      },
    );
  }
}
