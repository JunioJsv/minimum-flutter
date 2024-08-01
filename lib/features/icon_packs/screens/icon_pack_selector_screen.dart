import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';
import 'package:minimum/features/applications/widgets/list_entry.dart';
import 'package:minimum/features/applications/widgets/sliver_applications.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/icon_pack.dart';
import 'package:minimum/routes.dart';
import 'package:minimum/services/applications_manager_service.dart';

class IconPackSelectorScreenArguments {
  final void Function(IconPack? value) onSelect;

  const IconPackSelectorScreenArguments({
    required this.onSelect,
  });

  static IconPackSelectorScreenArguments of(BuildContext context) {
    return ModalRoute.of(context)!.arguments();
  }
}

class IconPackSelectorScreen extends StatefulWidget {
  static final String route = '$IconPackSelectorScreen';

  const IconPackSelectorScreen({super.key});

  @override
  State<IconPackSelectorScreen> createState() => _IconPackSelectorScreenState();
}

class _IconPackSelectorScreenState extends State<IconPackSelectorScreen> {
  final ApplicationsManagerService service = dependencies();
  late final iconPacks = service.getIconPacks();

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    final arguments = IconPackSelectorScreenArguments.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translation.iconPacks),
      ),
      body: FutureBuilder<IList<IconPack>>(
        future: iconPacks,
        builder: (context, snapshot) {
          final entries = [
            ListEntry(
              key: const ValueKey('system'),
              arguments: EntryWidgetArguments(
                icon: const ApplicationIcon(),
                label: translation.standard,
                onTap: () {
                  Navigator.pop(context);
                  arguments.onSelect(null);
                },
                onLongTap: () {},
              ),
            ),
            ...?snapshot.data?.map((iconPack) {
              return ListEntry(
                key: ValueKey(iconPack.package),
                arguments: EntryWidgetArguments(
                  icon: ApplicationIcon(package: iconPack.package),
                  label: iconPack.label,
                  onTap: () {
                    Navigator.pop(context);
                    arguments.onSelect(iconPack);
                  },
                  onLongTap: () {},
                ),
              );
            })
          ];
          final layout = SliverApplicationsListLayout(children: entries);
          return CustomScrollView(
            slivers: [
              SliverApplications(layout: layout),
            ],
          );
        },
      ),
    );
  }
}
