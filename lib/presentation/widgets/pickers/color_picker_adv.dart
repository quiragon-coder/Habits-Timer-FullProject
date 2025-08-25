import 'package:flutter/material.dart';

String _toHex(Color c) {
  return '#${c.red.toRadixString(16).padLeft(2, '0')}${c.green.toRadixString(16).padLeft(2, '0')}${c.blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
}

Color _fromHex(String hex) {
  var s = hex.trim().toUpperCase();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s';
  final v = int.parse(s, radix: 16);
  return Color(v);
}

final List<Color> kPresetColors = [
  Color(0xFF6750A4), Color(0xFF386641), Color(0xFF006D77), Color(0xFF8D99AE),
  Color(0xFFE07A5F), Color(0xFFEF476F), Color(0xFFF2C14E), Color(0xFF00A896),
  Color(0xFF2196F3), Color(0xFF3F51B5), Color(0xFF2D3142), Color(0xFFFFA62B),
];

Future<String?> showColorPickerDialog(BuildContext context, {String? initialHex}) async {
  Color current = initialHex != null ? _fromHex(initialHex) : kPresetColors.first;
  double h = HSVColor.fromColor(current).hue;
  double s = HSVColor.fromColor(current).saturation;
  double v = HSVColor.fromColor(current).value;

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Choisir une couleur'),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Presets grid
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                for (final c in kPresetColors)
                  GestureDetector(
                    onTap: () { Navigator.pop(ctx, _toHex(c)); },
                    child: Container(width: 32, height: 32, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.black12))),
                  ),
                GestureDetector(
                  onTap: () {}, // no-op
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: Theme.of(ctx).colorScheme.primary),
                    ),
                    child: const Center(child: Text('+', style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Advanced HSV sliders
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.surfaceVariant.withOpacity(.3), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(height: 36, decoration: BoxDecoration(color: HSVColor.fromAHSV(1, h, s, v).toColor(), borderRadius: BorderRadius.circular(8))),
                  const SizedBox(height: 8),
                  const Text('Teinte'),
                  Slider(min: 0, max: 360, value: h, onChanged: (x) { h = x; current = HSVColor.fromAHSV(1, h, s, v).toColor(); }),
                  const Text('Saturation'),
                  Slider(min: 0, max: 1, value: s, onChanged: (x) { s = x; current = HSVColor.fromAHSV(1, h, s, v).toColor(); }),
                  const Text('Luminosité'),
                  Slider(min: 0, max: 1, value: v, onChanged: (x) { v = x; current = HSVColor.fromAHSV(1, h, s, v).toColor(); }),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(ctx, _toHex(current)), child: const Text('Choisir')),
      ],
    ),
  );
}
