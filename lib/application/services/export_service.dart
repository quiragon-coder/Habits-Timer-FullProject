import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/heatmap_provider.dart';
import '../../presentation/pages/heatmap_overview_page.dart' show dailyTotalsProvider;

class ExportResult {
  final String filename;
  final String mimeType;
  final String content; // UTF-8
  const ExportResult({required this.filename, required this.mimeType, required this.content});
}

class ExportService {
  static Future<ExportResult> exportCsv(WidgetRef ref, int activityId, {String activityName = 'activity'}) async {
    final data = await ref.read(last365DaysHeatmapProvider(activityId).future);
    final buf = StringBuffer('date,minutes\n');
    for (final d in data) {
      final day = d.day.toIso8601String().split('T').first;
      buf.writeln('$day,${d.minutes}');
    }
    final content = buf.toString();
    return ExportResult(filename: '${activityName}_last365.csv', mimeType: 'text/csv', content: content);
  }

  static Future<ExportResult> exportJson(WidgetRef ref, int activityId, {String activityName = 'activity'}) async {
    final data = await ref.read(last365DaysHeatmapProvider(activityId).future);
    final jsonList = [
      for (final d in data)
        {
          'date': d.day.toIso8601String().split('T').first,
          'minutes': d.minutes,
        }
    ];
    final content = const JsonEncoder.withIndent('  ').convert(jsonList);
    return ExportResult(filename: '${activityName}_last365.json', mimeType: 'application/json', content: content);
  }

  static Future<ExportResult> exportCsvRange(WidgetRef ref, int activityId, DateTime startLocal, DateTime endLocal, {String activityName = 'activity'}) async {
    final totals = await ref.read(dailyTotalsProvider((activityId: activityId, startLocal: startLocal, endLocal: endLocal)).future);
    final buf = StringBuffer('date,minutes\n');

    if (totals is Map) {
      final keys = totals.keys.whereType<DateTime>().toList()..sort();
      for (final k in keys) {
        final v = totals[k];
        final minutes = v is Duration ? v.inMinutes : (v is int ? v : 0);
        buf.writeln('${k.toIso8601String().split('T').first},$minutes');
      }
    } else if (totals is List) {
      for (final t in totals) {
        try {
          final dyn = t as dynamic;
          final DateTime? d = dyn.date ?? dyn.day ?? (dyn['date'] as DateTime?);
          final minutes = dyn.minutes ?? (dyn['minutes'] as int?) ?? (dyn.duration is Duration ? (dyn.duration as Duration).inMinutes : 0);
          if (d != null) {
            final day = DateTime(d.year, d.month, d.day);
            buf.writeln('${day.toIso8601String().split('T').first},$minutes');
          }
        } catch (_) {}
      }
    }

    final content = buf.toString();
    final startStr = startLocal.toIso8601String().split('T').first;
    final endStr = endLocal.toIso8601String().split('T').first;
    return ExportResult(filename: '${activityName}_${startStr}_${endStr}.csv', mimeType: 'text/csv', content: content);
  }

  static Future<ExportResult> exportJsonRange(WidgetRef ref, int activityId, DateTime startLocal, DateTime endLocal, {String activityName = 'activity'}) async {
    final totals = await ref.read(dailyTotalsProvider((activityId: activityId, startLocal: startLocal, endLocal: endLocal)).future);
    final out = <Map<String, dynamic>>[];

    if (totals is Map) {
      final keys = totals.keys.whereType<DateTime>().toList()..sort();
      for (final k in keys) {
        final v = totals[k];
        final minutes = v is Duration ? v.inMinutes : (v is int ? v : 0);
        out.add({'date': k.toIso8601String().split('T').first, 'minutes': minutes});
      }
    } else if (totals is List) {
      for (final t in totals) {
        try {
          final dyn = t as dynamic;
          final DateTime? d = dyn.date ?? dyn.day ?? (dyn['date'] as DateTime?);
          final minutes = dyn.minutes ?? (dyn['minutes'] as int?) ?? (dyn.duration is Duration ? (dyn.duration as Duration).inMinutes : 0);
          if (d != null) {
            final day = DateTime(d.year, d.month, d.day);
            out.add({'date': day.toIso8601String().split('T').first, 'minutes': minutes});
          }
        } catch (_) {}
      }
    }

    final content = const JsonEncoder.withIndent('  ').convert(out);
    final startStr = startLocal.toIso8601String().split('T').first;
    final endStr = endLocal.toIso8601String().split('T').first;
    return ExportResult(filename: '${activityName}_${startStr}_${endStr}.json', mimeType: 'application/json', content: content);
  }

  static Future<void> copyToClipboard(ExportResult r) async {
    await Clipboard.setData(ClipboardData(text: r.content));
  }
}
