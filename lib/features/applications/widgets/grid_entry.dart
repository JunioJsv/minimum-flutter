import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';

class GridEntry extends EntryWidget {
  const GridEntry({
    super.key,
    required super.icon,
    required super.label,
    required super.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 48, maxWidth: 48),
                  child: icon,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ),
    );
  }
}
