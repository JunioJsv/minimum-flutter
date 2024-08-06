import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';
import 'package:minimum/features/applications/widgets/grid_entry.dart';
import 'package:minimum/features/applications/widgets/sliver_applications.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/icon_pack.dart';
import 'package:minimum/models/icon_pack_drawable.dart';
import 'package:minimum/routes.dart';
import 'package:minimum/services/applications_manager_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final iconPack = arguments.iconPack;
    return Scaffold(
      appBar: AppBar(
        title: Text(iconPack.label),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: drawables,
        builder: (context, snapshot) {
          final drawables = snapshot.data;
          if (drawables == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final children = drawables.mapTo(
            (component, name) {
              final drawable = IconPackDrawable(
                name: name,
                component: component,
                package: iconPack.package,
              );
              return GridEntry(
                arguments: EntryWidgetArguments(
                  icon: ApplicationIcon.fromIconPack(
                    drawable: drawable,
                    keepAlive: false,
                  ),
                  label: name,
                  onTap: () {
                    arguments.onSelect(drawable);
                    Navigator.pop(context);
                  },
                  onLongTap: () {},
                ),
              );
            },
          );

          final layout = SliverApplicationsGridLayout(
            delegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            children: children,
          );

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverApplications(layout: layout),
              const SliverToBoxAdapter(child: SizedBox(height: kToolbarHeight)),
            ],
          );
        },
      ),
    );
  }
}
