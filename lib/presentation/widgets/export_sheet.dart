import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/services/export_service.dart';
import '../../application/services/haptics_service.dart';
import '../../application/providers/settings_provider.dart';

class ExportSheet extends ConsumerWidget {
  final int activityId;
  final String activityName;
  const ExportSheet({super.key, required this.activityId, required this.activityName});

  Future<void> _pickAndExport(BuildContext context, WidgetRef ref, {required bool json}) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 3, 1, 1);
    final last = DateTime(now.year + 1, 12, 31);
    final range = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDateRange: DateTimeRange(start: DateTime(now.year, now.month, 1), end: DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1))),
    );
    if (range == null) return;

    final settings = ref.read(settingsProvider);
    final haptics = HapticsService(enabled: settings.hapticsEnabled);

    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(range.end.year, range.end.month, range.end.day).add(const Duration(days: 1));

    final result = json
        ? await ExportService.exportJsonRange(ref, activityId, start, end, activityName: activityName)
        : await ExportService.exportCsvRange(ref, activityId, start, end, activityName: activityName);

    await ExportService.copyToClipboard(result);
    if (context.mounted) {
      haptics.play();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${json ? 'JSON' : 'CSV'} copié pour la période choisie')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exporter "$activityName"', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV (365 jours)'),
              subtitle: const Text('date, minutes'),
              onTap: () async {
                final r = await ExportService.exportCsv(ref, activityId, activityName: activityName);
                await ExportService.copyToClipboard(r);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV (365 j) copié')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_object),
              title: const Text('JSON (365 jours)'),
              onTap: () async {
                final r = await ExportService.exportJson(ref, activityId, activityName: activityName);
                await ExportService.copyToClipboard(r);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON (365 j) copié')));
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('CSV (période choisie)'),
              onTap: () => _pickAndExport(context, ref, json: false),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('JSON (période choisie)'),
              onTap: () => _pickAndExport(context, ref, json: true),
            ),
          ],
        ),
      ),
    );
  }
}
