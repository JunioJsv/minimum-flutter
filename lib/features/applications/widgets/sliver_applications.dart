import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';
import 'package:minimum/features/applications/widgets/grid_entry.dart';
import 'package:minimum/features/applications/widgets/list_entry.dart';

sealed class SliverApplicationsLayout {
  final Iterable<EntryWidget> children;

  SliverApplicationsLayout({required this.children});
}

class SliverApplicationsListLayout extends SliverApplicationsLayout {
  SliverApplicationsListLayout({required Iterable<ListEntry> children})
    : super(children: children);
}

class SliverApplicationsGridLayout extends SliverApplicationsLayout {
  final SliverGridDelegateWithFixedCrossAxisCount delegate;

  SliverApplicationsGridLayout({
    required this.delegate,
    required Iterable<GridEntry> children,
  }) : super(children: children);
}

class SliverApplications extends StatelessWidget {
  final SliverApplicationsLayout _layout;

  const SliverApplications({
    super.key,
    required SliverApplicationsLayout layout,
  }) : _layout = layout;

  @override
  Widget build(BuildContext context) {
    final children = _layout.children;
    final indexLookupTable =
        children is List<EntryWidget>
            ? Map.fromEntries(
              children.mapIndexed((index, entry) => MapEntry(entry.key, index)),
            )
            : null;
    int? findChildIndexCallback(Key key) {
      final index = indexLookupTable?[key];
      return index;
    }

    if (_layout is SliverApplicationsGridLayout) {
      return SliverGrid(
        gridDelegate: _layout.delegate,
        delegate: SliverChildBuilderDelegate(
          findChildIndexCallback: findChildIndexCallback,
          childCount: children.length,
          (context, index) {
            return children.elementAt(index);
          },
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        findChildIndexCallback: findChildIndexCallback,
        childCount: children.length,
        (context, index) {
          return children.elementAt(index);
        },
      ),
    );
  }
}
