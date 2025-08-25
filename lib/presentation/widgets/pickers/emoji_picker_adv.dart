import 'package:flutter/material.dart';

const List<String> kCuratedEmojis = [
  '🎨','✏️','🧠','📚','💪','🏃','🧘','🎸','🎹','🎧','🧩','🧵','🧑‍🍳','🥗','🧼','🧹','📓','⌛','🕹️','💻','🛠️','🧪','🌱','🎯',
];

const List<String> kExtendedEmojis = [
  '🍎','🍔','🍣','🍪','🍺','☕','🍵','🍫','🍰','🥐','🥑','🥕','🍇','🍌','🍉','🌮','🍝','🍳',
  '⚽','🏀','🏈','🎾','🏐','🏓','🏸','🏒','⛳','🥊','🧗','🚴','🏊','🚶',
  '🎬','🎮','🎼','🎻','🎷','🎺','🥁','🎤','🎭',
  '📷','📹','🎨','🖌️','🧵','🧩','🧠','📚','✍️','📝','🔬','🧪','💻','🛠️','🧰','🔧',
  '🌱','🌿','🌻','🌳','🌍','🌙','⭐','☀️','🔥','💧','⛰️',
  '💤','💡','❤️','✨','✅','🕒','📈','🎯','🏆','🏅','🎖️',
];

Future<String?> showEmojiPickerDialog(BuildContext context, {String? initialEmoji}) async {
  String? selected = initialEmoji;
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Choisir un emoji'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                for (final e in kCuratedEmojis)
                  InkWell(
                    onTap: () => Navigator.pop(ctx, e),
                    child: Container(
                      width: 36, height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).colorScheme.surfaceVariant.withOpacity(.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                InkWell(
                  onTap: () {}, // open extended below
                  child: Container(
                    width: 36, height: 36, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(ctx).colorScheme.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('+', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8, mainAxisSpacing: 6, crossAxisSpacing: 6),
                itemCount: kExtendedEmojis.length,
                itemBuilder: (_, i) {
                  final e = kExtendedEmojis[i];
                  return InkWell(
                    onTap: () => Navigator.pop(ctx, e),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).colorScheme.surfaceVariant.withOpacity(.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 18)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
      ],
    ),
  );
}
