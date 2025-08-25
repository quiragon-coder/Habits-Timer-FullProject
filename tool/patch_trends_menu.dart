
import 'dart:io';

void main() {
  final file = File('lib/presentation/pages/activities_home_page.dart');
  if (!file.existsSync()) {
    stderr.writeln('Fichier non trouvé: lib/presentation/pages/activities_home_page.dart');
    exit(1);
  }
  var text = file.readAsStringSync();

  // 1) Import StatsTrendsPage si absent
  const importLine = "import './stats_trends_page.dart';";
  if (!text.contains(importLine)) {
    final match = RegExp(r"^import .+;$", multiLine: true).allMatches(text).toList();
    if (match.isNotEmpty) {
      final last = match.last;
      final insertAt = last.end;
      text = text.substring(0, insertAt) + "\n" + importLine + text.substring(insertAt);
      stdout.writeln("→ Import ajouté: " + importLine);
    } else {
      text = importLine + "\n" + text;
      stdout.writeln("→ Import ajouté en tête de fichier.");
    }
  } else {
    stdout.writeln("✓ Import déjà présent.");
  }

  // 2) Envelopper le 'return ActivityTile(...)' dans un Stack avec un PopupMenuButton "Tendances"
  final re = RegExp(r"return\s+ActivityTile\(([\s\S]*?)\);\s*", multiLine: true);
  final m = re.firstMatch(text);
  if (m == null) {
    stderr.writeln("Impossible de localiser 'return ActivityTile(...)' pour insérer le menu.");
    exit(2);
  }
  final args = m.group(1)!;

  var replacement = """
return Stack(
  children: [
    ActivityTile(
      %ARGS%
    ),
    Positioned(
      right: 8,
      top: 8,
      child: PopupMenuButton<String>(
        tooltip: 'Plus',
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'trends', child: Text('Tendances')),
        ],
        onSelected: (value) {
          if (value == 'trends') {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => StatsTrendsPage(
                activityId: a.id,
                activityName: a.name,
              ),
            ));
          }
        },
      ),
    ),
  ],
);
""";

  // Dart String doesn't have .replace – use replaceAll.
  replacement = replacement.replaceAll("%ARGS%", args);

  // Avoid double-patching
  if (text.contains("PopupMenuButton<String>") && text.contains("StatsTrendsPage(")) {
    stdout.writeln("✓ Le menu 'Tendances' semble déjà présent — patch non appliqué.");
  } else {
    text = text.replaceRange(m.start, m.end, replacement);
    stdout.writeln("✅ Bouton 'Tendances' ajouté au menu de chaque activité.");
  }

  file.writeAsStringSync(text);
}
