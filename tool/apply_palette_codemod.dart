import 'dart:io';

final _withOpacity = RegExp(r'\.withOpacity\s*\(\s*([^)]+)\)');

String replaceWithOpacity(String src) =>
    src.replaceAllMapped(_withOpacity, (m) => '.withValues(alpha: ${m[1]})');

String ensureImport(String src, String importLine) {
  if (!src.contains(importLine)) {
    src = src.replaceFirst(
      "import 'package:flutter/material.dart';",
      "import 'package:flutter/material.dart';\n$importLine",
    );
  }
  return src;
}

String patchHeatmapFile(String src) {
  src = ensureImport(src, "import '../../application/providers/palette_provider.dart';");
  src = ensureImport(src, "import '../widgets/heatmap_colors.dart';");

  // Inject palette on first build method
  final buildIdx = src.indexOf(RegExp(r'Widget\s+build\s*\(\s*BuildContext\s+context'));
  if (buildIdx != -1 && !src.contains('final pal = ref.watch(')) {
    final braceIdx = src.indexOf('{', buildIdx);
    if (braceIdx != -1) {
      src = src.substring(0, braceIdx + 1)
          + "\n    final pal = ref.watch(globalPaletteProvider);\n    final scale = heatmapScale(pal);\n"
          + src.substring(braceIdx + 1);
    }
  }

  // Simple mapping from old opacities to scale buckets
  src = src.replaceAll("cs.primary.withValues(alpha: 0.15)", "scale[0]");
  src = src.replaceAll("cs.primary.withValues(alpha: 0.25)", "scale[1]");
  src = src.replaceAll("cs.primary.withValues(alpha: 0.35)", "scale[2]");
  src = src.replaceAll("cs.primary.withValues(alpha: 0.50)", "scale[3]");
  src = src.replaceAll("cs.primary.withValues(alpha: 0.70)", "scale[4]");

  return src;
}

void main(List<String> args) async {
  final root = args.isNotEmpty ? args.first : '.';
  final dir = Directory(root);
  if (!dir.existsSync()) {
    stderr.writeln('Path not found: $root');
    exit(2);
  }

  final lib = Directory('${dir.path}/lib');
  if (!lib.existsSync()) {
    stderr.writeln('No lib/ directory found in $root');
    exit(3);
  }

  int changed = 0;
  for (final f in lib
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))) {
    final original = await f.readAsString();
    var src = original;

    // 1) Replace withOpacity -> withValues
    src = replaceWithOpacity(src);

    // 2) Palette on heatmap pages
    final name = f.uri.pathSegments.last;
    if (name == 'heatmap_overview_page.dart' || name == 'mini_heatmap_section.dart') {
      src = patchHeatmapFile(src);
    }

    if (src != original) {
      await f.writeAsString(src);
      stdout.writeln('Patched ${f.path.replaceFirst(dir.path + Platform.pathSeparator, "")}');
      changed++;
    }
  }

  stdout.writeln('Done. Files changed: $changed');
}
