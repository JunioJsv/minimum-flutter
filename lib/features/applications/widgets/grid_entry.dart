import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';

class GridEntry extends EntryWidget {
  const GridEntry({
    super.key,
    required super.arguments,
  });

  @override
  Widget build(BuildContext context) {
    final EntryWidgetArguments(
      :label,
      :icon,
      :onTap,
      :onLongTap,
    ) = arguments;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      onLongPress: onLongTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 48, maxWidth: 48),
                child: icon,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2)
                    .add(const EdgeInsets.only(top: 8)),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
