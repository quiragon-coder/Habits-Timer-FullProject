import 'package:flutter/material.dart';
import 'dart:math' as math;

class ColorPickerDialog extends StatefulWidget {
  final Color initial;
  const ColorPickerDialog({super.key, required this.initial});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choisir une couleur'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: _hsv.toColor(),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
          ),
          const SizedBox(height: 12),
          _slider('Teinte', 0, 360, _hsv.hue, (v) => setState(() => _hsv = _hsv.withHue(v))),
          _slider('Saturation', 0, 1, _hsv.saturation, (v) => setState(() => _hsv = _hsv.withSaturation(v))),
          _slider('Lumière', 0, 1, _hsv.value, (v) => setState(() => _hsv = _hsv.withValue(v))),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(context, _hsv.toColor()), child: const Text('OK')),
      ],
    );
  }

  Widget _slider(String label, double min, double max, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
