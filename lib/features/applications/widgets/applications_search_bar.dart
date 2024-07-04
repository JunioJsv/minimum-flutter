import 'package:flutter/material.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';
import 'package:minimum/features/applications/widgets/list_entry.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/models/application.dart';

class ApplicationsSearchBar extends StatefulWidget {
  final List<Application> applications;

  const ApplicationsSearchBar({super.key, required this.applications});

  @override
  State<ApplicationsSearchBar> createState() => _ApplicationsSearchBarState();
}

class _ApplicationsSearchBarState extends State<ApplicationsSearchBar> {
  final focusNode = FocusNode();
  final controller = SearchController();

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    final applications = widget.applications;
    final screen = context.findAncestorStateOfType<ApplicationsScreenState>()!;
    return SearchAnchor(
      searchController: controller,
      dividerColor: Theme.of(context).colorScheme.outlineVariant,
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
                      await screen.onApplicationTap(application);
                      controller.closeView('');
                      focusNode.unfocus();
                    },
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
