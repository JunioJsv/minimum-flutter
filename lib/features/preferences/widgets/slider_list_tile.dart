import 'package:flutter/material.dart';
import 'package:minimum/i18n/translations.g.dart';

class SliderListTile extends StatefulWidget {
  final int value;
  final void Function(int value) onChange;
  final int min;
  final int max;

  const SliderListTile({
    super.key,
    required this.value,
    required this.onChange,
    required this.min,
    required this.max,
  });

  @override
  State<SliderListTile> createState() => _SliderListTileState();
}

class _SliderListTileState extends State<SliderListTile> {
  late double _value = widget.value.toDouble().clamp(
        widget.min.toDouble(),
        widget.max.toDouble(),
      );

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    return ListTile(
      title: Text(translation.gridCrossAxisCount),
      subtitle: SliderTheme(
        data: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
          showValueIndicator: ShowValueIndicator.always,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Slider(
            value: _value,
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            label: '${_value.round()}',
            onChanged: (value) {
              setState(() {
                _value = value;
              });
            },
            onChangeEnd: (value) {
              widget.onChange(value.round());
            },
            divisions: widget.max - widget.min,
          ),
        ),
      ),
    );
  }
}
