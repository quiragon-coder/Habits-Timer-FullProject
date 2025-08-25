import 'package:flutter/material.dart';
import '../../infrastructure/db/database.dart';
import '../pages/activity_detail_page.dart';
import '../pages/activity_edit_page.dart';
import 'package:intl/intl.dart';
import '../utils/haptics.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onChanged; // call after edit
  const ActivityTile({super.key, required this.activity, this.onChanged});

  String _date(DateTime d) => DateFormat.yMMMd().format(d);

  @override
  Widget build(BuildContext context) {
    final created = DateTime.fromMillisecondsSinceEpoch(activity.createdAtUtc * 1000, isUtc: true).toLocal();
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Haptics.tap();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ActivityDetailPage(activityId: activity.id),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(activity.emoji ?? '🕒', style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Créée le ${_date(created)}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Éditer',
                onPressed: () async {
                  Haptics.tap();
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ActivityEditPage(activityId: activity.id),
                  ));
                  onChanged?.call();
                },
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
