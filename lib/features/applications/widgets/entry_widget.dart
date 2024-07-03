import 'package:flutter/material.dart';

abstract class EntryWidget extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const EntryWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
