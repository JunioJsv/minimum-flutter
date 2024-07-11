import 'package:flutter/material.dart';

final class EntryWidgetArguments {
  final String? id;
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onLongTap;

  const EntryWidgetArguments({
    this.id,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.onLongTap,
  });
}

abstract class EntryWidget extends StatelessWidget {
  final EntryWidgetArguments arguments;

  const EntryWidget({super.key, required this.arguments});
}
