import 'package:flutter/material.dart';

final class EntryWidgetArguments {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const EntryWidgetArguments({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

abstract class EntryWidget extends StatelessWidget {
  final EntryWidgetArguments arguments;

  const EntryWidget({super.key, required this.arguments});
}
