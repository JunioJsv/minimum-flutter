import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';
import 'package:minimum/features/applications/widgets/grid_entry.dart';
import 'package:minimum/features/applications/widgets/sliver_applications.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/icon_pack.dart';
import 'package:minimum/models/icon_pack_drawable.dart';
import 'package:minimum/routes.dart';
import 'package:minimum/services/applications_manager_service.dart';
import 'package:minimum/widgets/sliver_search_bar.dart';
import 'package:minimum/widgets/warning_container.dart';

class IconPackDrawableSelectorScreenArguments {
  final IconPack iconPack;

  final void Function(IconPackDrawable? drawable) onSelect;

  const IconPackDrawableSelectorScreenArguments({
    required this.iconPack,
    required this.onSelect,
  });

  static IconPackDrawableSelectorScreenArguments of(BuildContext context) {
    return ModalRoute.of(context)!.arguments();
  }
}

class IconPackDrawableSelectorScreen extends StatefulWidget {
  static final String route = '$IconPackDrawableSelectorScreen';

  const IconPackDrawableSelectorScreen({super.key});

  @override
  State<IconPackDrawableSelectorScreen> createState() =>
      _IconPackDrawableSelectorScreenState();
}

class _IconPackDrawableSelectorScreenState
    extends State<IconPackDrawableSelectorScreen> {
  late final arguments = IconPackDrawableSelectorScreenArguments.of(context);
  final service = dependencies<ApplicationsManagerService>();
  late final drawables = service.getIconPackDrawables(
    arguments.iconPack.package,
  );

  String? query;
  Timer? queryDebounce;

  static Future<Map<String, String>> filterDrawables(
    Map<String, String> drawables,
    String query,
  ) async {
    return Map<String, String>.fromEntries(
      drawables.entries.where((entry) {
        return entry.value.toLowerCase().contains(query.toLowerCase());
      }),
    );
  }

  @override
  void dispose() {
    if (queryDebounce?.isActive == true) {
      queryDebounce?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconPack = arguments.iconPack;
    final theme = Theme.of(context);
    final translation = context.translations;
    return Scaffold(
      appBar: AppBar(title: Text(iconPack.label)),
      body: FutureBuilder<Map<String, String>>(
        future: drawables.then((drawables) async {
          final query = this.query;
          if (query == null) return drawables;

          return filterDrawables(drawables, query);
        }),
        builder: (context, snapshot) {
          final drawables = snapshot.data;
          if (drawables == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final children = drawables.mapTo((component, name) {
            final drawable = IconPackDrawable(
              name: name,
              component: component,
              package: iconPack.package,
            );
            return GridEntry(
              key: ValueKey(component),
              arguments: EntryWidgetArguments(
                icon: ApplicationIcon.fromIconPack(
                  drawable: drawable,
                  keepAlive: false,
                ),
                label: name,
                onTap: () {
                  Navigator.pop(context);
                  arguments.onSelect(drawable);
                },
                onLongTap: () {},
              ),
            );
          });

          final layout = SliverApplicationsGridLayout(
            delegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 3 / 4,
            ),
            children: children,
          );

          return CustomScrollView(
            slivers: [
              SliverSearchBar(
                padding: const EdgeInsets.all(16),
                onChange: (query) {
                  if (queryDebounce?.isActive == true) {
                    queryDebounce?.cancel();
                  }
                  queryDebounce = Timer(const Duration(milliseconds: 400), () {
                    setState(() {
                      this.query = query.isNotEmpty ? query : null;
                    });
                  });
                },
              ),
              if (children.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: WarningContainer(
                      icon: Icons.search_off,
                      color: theme.colorScheme.onSurface,
                      message: translation.noResultsFor(query: query ?? ''),
                    ),
                  ),
                )
              else
                SliverApplications(layout: layout),
              const SliverToBoxAdapter(child: SizedBox(height: kToolbarHeight)),
            ],
          );
        },
      ),
    );
  }
}
