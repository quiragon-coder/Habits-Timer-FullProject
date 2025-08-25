import 'package:flutter/material.dart';

const _curated = [
  '🎨','✍️','📚','🧠','💻','🧘','🏃','🚴','🏋️','🎹','🎸','🥁','🎮','🧑‍🍳','🍳','🍽️','🧼','🧺','🧹',
  '🧑‍🎓','📖','🧑‍🏫','🧑‍🔬','🧪','🔭','🧑‍🔧','🔧','🪛','🪚','🧵','🪡','🧶','🧑‍🌾','🌱','🌿','🌳',
  '🧑‍🎤','🎤','🎧','🎼','🎯','📷','🎥','✂️','🧩','♟️','🧩','🧩','🧑‍🚀','🚀','🧗','🏊','⛷️','⛳',
  '🧑‍💻','📝','🗂️','🗓️','⏱️',
];

const _more = [
  '🧘‍♀️','🧘‍♂️','🤸','🤾','⛹️','🏌️','🏇','🏄','🚣','🚵','🧗‍♀️','🧗‍♂️','🏊‍♀️','🏊‍♂️','🚴‍♀️','🚴‍♂️',
  '🎻','🎺','🪗','🪘','🪕','🎭','🎬','🎨','🧵','🪡','🧶','🧩','🧠','📚','📖','🗞️','📰','🧪','🔬','🔭',
  '🧑‍🍳','🍰','🍪','🍞','🥐','🥗','🍎','🍌','🍊','🥕','🍅','🧄','🧅','🥔','🥦','🥒','🌶️','🧃',
  '🧑‍🌾','🌻','🌼','🌷','🌵','🌲','🍀','🌿','🍃','🌳',
  '🧑‍🔧','⚙️','🔩','🔧','🪚','🪛','🔨','🛠️','🧰',
  '🧑‍🎓','🧑‍🏫','🧑‍🔬','🧑‍💻','🧑‍🚀','🧑‍🎤',
  '✍️','📝','🗂️','🗓️','📅','📈','📉','📊','📎','📌','🖇️',
  '⏱️','⏰','🕰️',
];

class EmojiPickerSheet extends StatelessWidget {
  final String initial;
  final bool showMore;
  const EmojiPickerSheet({super.key, required this.initial, this.showMore = false});

  @override
  Widget build(BuildContext context) {
    final list = showMore ? _more : _curated;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(showMore ? 'Plus d’emoji' : 'Emoji', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.2),
                itemCount: list.length,
                itemBuilder: (_, i) => InkWell(
                  onTap: () => Navigator.pop(context, list[i]),
                  child: Center(child: Text(list[i], style: const TextStyle(fontSize: 24))),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Ou collez un emoji :'),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    final v = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        final c = TextEditingController();
                        return AlertDialog(
                          title: const Text('Entrer un emoji'),
                          content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(hintText: '🙂')),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                            FilledButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('OK')),
                          ],
                        );
                      },
                    );
                    if (context.mounted && v != null && v.isNotEmpty) Navigator.pop(context, v);
                  },
                  child: const Text('Saisir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
