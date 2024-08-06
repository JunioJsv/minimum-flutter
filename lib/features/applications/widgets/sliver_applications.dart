import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';
import 'package:minimum/features/applications/widgets/grid_entry.dart';
import 'package:minimum/features/applications/widgets/list_entry.dart';

sealed class SliverApplicationsLayout {
  final Iterable<EntryWidget> children;

  SliverApplicationsLayout({required this.children});
}

class SliverApplicationsListLayout extends SliverApplicationsLayout {
  SliverApplicationsListLayout({
    required Iterable<ListEntry> children,
  }) : super(children: children);
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

    if (_layout is SliverApplicationsGridLayout) {
      return SliverGrid(
        gridDelegate: _layout.delegate,
        delegate: SliverChildBuilderDelegate(
          childCount: children.length,
          (context, index) {
            return children.elementAt(index);
          },
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: children.length,
        (context, index) {
          final child = children.elementAt(index);
          return Column(
            children: [
              child,
              const Divider(height: 0),
            ],
          );
        },
      ),
    );
  }
}
