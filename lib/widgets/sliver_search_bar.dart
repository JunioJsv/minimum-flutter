import 'package:flutter/material.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/utils/ancestral_scrollable_mixin.dart';

class SliverSearchBar extends StatefulWidget {
  final EdgeInsets padding;
  final void Function(String query) onChange;

  const SliverSearchBar({
    super.key,
    this.padding = EdgeInsets.zero,
    required this.onChange,
  });

  @override
  State<SliverSearchBar> createState() => _SliverSearchBarState();
}

class _SliverSearchBarState extends State<SliverSearchBar>
    with AncestralScrollableMixin {
  final FocusNode focusNode = FocusNode();
  final controller = TextEditingController();

  @override
  void didChangeAncestralScrollablePosition() {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverSearchBarDelegate(
        controller: controller,
        focusNode: focusNode,
        padding: widget.padding,
        onChange: widget.onChange,
      ),
      pinned: true,
    );
  }
}

class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final EdgeInsets padding;
  final void Function(String query) onChange;
  final FocusNode focusNode;
  final TextEditingController controller;

  const _SliverSearchBarDelegate({
    required this.controller,
    required this.focusNode,
    required this.padding,
    required this.onChange,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final translation = context.translations;
    return Padding(
      padding: padding,
      child: SearchBar(
        controller: controller,
        focusNode: focusNode,
        leading: const Icon(Icons.search),
        hintText: translation.search,
        onChanged: onChange,
        trailing: [
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              return IconButton(
                onPressed: value.text.isNotEmpty
                    ? () {
                        controller.clear();
                        onChange('');
                      }
                    : null,
                icon: const Icon(Icons.clear),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 56 + padding.vertical;

  @override
  double get minExtent => maxExtent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
