import 'package:flutter/material.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';
import 'package:minimum/features/applications/widgets/list_entry.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';

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
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
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
  Widget build(BuildContext context) {
    final translation = context.translations;
    final applications = widget.applications;
    final theme = Theme.of(context);
    return SearchAnchor(
      searchController: controller,
      dividerColor: theme.colorScheme.outlineVariant,
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
            return Column(
              key: ValueKey(application.package),
              mainAxisSize: MainAxisSize.min,
              children: [
                ListEntry(
                  arguments: EntryWidgetArguments(
                    icon: ApplicationIcon(package: application.package),
                    label: application.label,
                    onTap: () async {
                      await screen.onApplicationTap(context, application);
                      controller.closeView('');
                      focusNode.unfocus();
                    },
                    onLongTap: () {},
                  ),
                ),
                const Divider(height: 0),
              ],
            );
          },
        );
      },
    );
  }
}
