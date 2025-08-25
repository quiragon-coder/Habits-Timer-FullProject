import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/heatmap_provider.dart';
import '../../presentation/pages/heatmap_overview_page.dart' show dailyTotalsProvider;

class ExportResult {
  final String filename;
  final String mimeType;
  final String content;
  const ExportResult({required this.filename, required this.mimeType, required this.content});
}

int _toMinutes(dynamic v) {
  if (v is Duration) return v.inMinutes;
  if (v is int) return v;
  return 0;
}

class ExportService {
  static Future<ExportResult> exportCsv(WidgetRef ref, int activityId, {String activityName = 'activity'}) async {
    final days = await ref.read(last365DaysHeatmapProvider(activityId).future);
    final buf = StringBuffer('date,minutes\n');
    for (final d in days) {
      final day = d.day.toIso8601String().split('T').first;
      buf.writeln('$day,${d.minutes}');
    }
    final content = buf.toString();
    return ExportResult(filename: '${activityName}_last365.csv', mimeType: 'text/csv', content: content);
  }

  static Future<ExportResult> exportJson(WidgetRef ref, int activityId, {String activityName = 'activity'}) async {
    final days = await ref.read(last365DaysHeatmapProvider(activityId).future);
    final jsonList = [
      for (final d in days) {'date': d.day.toIso8601String().split('T').first, 'minutes': d.minutes}
    ];
    final content = const JsonEncoder.withIndent('  ').convert(jsonList);
    return ExportResult(filename: '${activityName}_last365.json', mimeType: 'application/json', content: content);
  }

  static Future<ExportResult> exportCsvRange(
    WidgetRef ref,
    int activityId,
    DateTime startLocal,
    DateTime endLocal, {
    String activityName = 'activity',
  }) async {
    // IMPORTANT: dynamic to allow both Map<DateTime, Duration|int> and List<dynamic> cases.
    final dynamic totals = await ref.read(
      dailyTotalsProvider((activityId: activityId, startLocal: startLocal, endLocal: endLocal)).future,
    );

    final buf = StringBuffer('date,minutes\n');

    if (totals is List) {
      for (final t in totals) {
        final dyn = t as dynamic;
        DateTime? d;
        int minutes = 0;
        try {
          final maybeDate = dyn.date ?? dyn.day ?? dyn['date'] ?? dyn['day'];
          if (maybeDate is DateTime) {
            d = DateTime(maybeDate.year, maybeDate.month, maybeDate.day);
          } else if (maybeDate is String) {
            final parsed = DateTime.tryParse(maybeDate);
            if (parsed != null) d = DateTime(parsed.year, parsed.month, parsed.day);
          }
          final m = dyn.minutes ?? dyn['minutes'];
          if (m is int) minutes = m;
          final dur = dyn.duration ?? dyn['duration'];
          if (dur is Duration) minutes = dur.inMinutes;
        } catch (_) {}
        if (d != null) {
          buf.writeln('${d.toIso8601String().split('T').first},$minutes');
        }
      }
    } else if (totals is Map) {
      final keys = totals.keys.whereType<DateTime>().toList()..sort();
      for (final k in keys) {
        final v = totals[k];
        final minutes = _toMinutes(v);
        buf.writeln('${k.toIso8601String().split('T').first},$minutes');
      }
    }

    final content = buf.toString();
    final startStr = startLocal.toIso8601String().split('T').first;
    final endStr = endLocal.toIso8601String().split('T').first;
    return ExportResult(filename: '${activityName}_${startStr}_${endStr}.csv', mimeType: 'text/csv', content: content);
  }

  static Future<ExportResult> exportJsonRange(
    WidgetRef ref,
    int activityId,
    DateTime startLocal,
    DateTime endLocal, {
    String activityName = 'activity',
  }) async {
    final dynamic totals = await ref.read(
      dailyTotalsProvider((activityId: activityId, startLocal: startLocal, endLocal: endLocal)).future,
    );

    final out = <Map<String, dynamic>>[];

    if (totals is List) {
      for (final t in totals) {
        final dyn = t as dynamic;
        DateTime? d;
        int minutes = 0;
        try {
          final maybeDate = dyn.date ?? dyn.day ?? dyn['date'] ?? dyn['day'];
          if (maybeDate is DateTime) {
            d = DateTime(maybeDate.year, maybeDate.month, maybeDate.day);
          } else if (maybeDate is String) {
            final parsed = DateTime.tryParse(maybeDate);
            if (parsed != null) d = DateTime(parsed.year, parsed.month, parsed.day);
          }
          final m = dyn.minutes ?? dyn['minutes'];
          if (m is int) minutes = m;
          final dur = dyn.duration ?? dyn['duration'];
          if (dur is Duration) minutes = dur.inMinutes;
        } catch (_) {}
        if (d != null) {
          out.add({'date': d.toIso8601String().split('T').first, 'minutes': minutes});
        }
      }
    } else if (totals is Map) {
      final keys = totals.keys.whereType<DateTime>().toList()..sort();
      for (final k in keys) {
        final v = totals[k];
        final minutes = _toMinutes(v);
        out.add({'date': k.toIso8601String().split('T').first, 'minutes': minutes});
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
