import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';

class ListEntry extends EntryWidget {
  const ListEntry({super.key, required super.arguments});

  @override
  Widget build(BuildContext context) {
    final EntryWidgetArguments(:label, :icon, :onTap, :onLongTap) = arguments;
    final child = ListTile(
      leading: SizedBox.square(dimension: 48, child: icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(label),
      onTap: onTap,
      onLongPress: onLongTap,
    );

    return Column(children: [child, const Divider(height: 0)]);
  }
}
