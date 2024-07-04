import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';

class ListEntry extends EntryWidget {
  const ListEntry({
    super.key,
    required super.arguments,
  });

  @override
  Widget build(BuildContext context) {
    final EntryWidgetArguments(:label, :icon, :onTap) = arguments;
    return ListTile(
      leading: SizedBox.square(
        dimension: 48,
        child: icon,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      title: Text(label),
      onTap: onTap,
    );
  }
}
