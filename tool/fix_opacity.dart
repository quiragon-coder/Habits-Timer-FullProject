import 'dart:io';

final regex = RegExp(r'\.withOpacity\(([^)]+)\)');

void main(List<String> args) {
  final root = Directory('lib');
  if (!root.existsSync()) {
    stderr.writeln('No lib/ directory found. Run this from the project root.');
    exit(1);
  }

  int filesChanged = 0;
  int replacements = 0;

  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.dart')) continue;

    final text = entity.readAsStringSync();
    if (!regex.hasMatch(text)) continue;

    final updated = text.replaceAllMapped(regex, (m) => '.withValues(alpha: ${m.group(1)})');
    if (updated != text) {
      entity.writeAsStringSync(updated);
      filesChanged++;
      replacements += regex.allMatches(text).length;
      stdout.writeln('Updated ${entity.path}');
    }
  }

  stdout.writeln('Done. Files changed: $filesChanged, replacements: $replacements');
}
