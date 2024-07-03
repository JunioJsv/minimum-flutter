import 'package:flutter/material.dart';
import 'package:minimum/i18n/translations.g.dart';

class ApplicationsSearchBar extends StatefulWidget {
  final void Function(String query) onChange;

  const ApplicationsSearchBar({
    super.key,
    required this.onChange,
  });

  @override
  State<ApplicationsSearchBar> createState() => _ApplicationsSearchBarState();
}

class _ApplicationsSearchBarState extends State<ApplicationsSearchBar> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    return TextField(
      controller: controller,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: translation.search,
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search),
      ),
      onChanged: widget.onChange,
    );
  }
}
