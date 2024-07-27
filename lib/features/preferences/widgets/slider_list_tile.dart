import 'package:flutter/material.dart';

class SliderListTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int value;
  final void Function(int value) onChange;
  final int min;
  final int max;
  final bool isEnabled;

  const SliderListTile({
    super.key,
    required this.value,
    this.isEnabled = true,
    required this.onChange,
    required this.min,
    required this.max,
    required this.title,
    this.subtitle,
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
    final subtitle = widget.subtitle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(widget.title),
          subtitle: subtitle != null ? Text(subtitle) : null,
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _value,
                min: widget.min.toDouble(),
                max: widget.max.toDouble(),
                // label: '${_value.round()}',
                onChanged: widget.isEnabled
                    ? (value) {
                        setState(() {
                          _value = value;
                        });
                      }
                    : null,
                onChangeEnd: (value) {
                  widget.onChange(value.round());
                },
                divisions: widget.max - widget.min,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 24),
              child: Text('${_value.round()}'),
            )
          ],
        ),
      ],
    );
  }
}
