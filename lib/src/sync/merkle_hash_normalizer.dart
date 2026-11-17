import 'hlc.dart';

/// Canonical normalization for Merkle [contentHash] computation.
///
/// Client and server must produce identical hashes for the same logical entity.
/// UI-only fields and legacy encodings are normalized here.
class MerkleHashNormalizer {
  static const resizePolicyNames = ['none', 'constrain', 'elastic'];

  static String normalizeResizePolicy(dynamic value) {
    if (value == null) return 'none';
    final asString = value.toString();
    final index = int.tryParse(asString);
    if (index != null && index >= 0 && index < resizePolicyNames.length) {
      return resizePolicyNames[index];
    }
    return asString;
  }

  static String? normalizeColorHex(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      if (value.startsWith('#')) return value.substring(1).toLowerCase();
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed.toRadixString(16).padLeft(6, '0');
      return value.toLowerCase();
    }
    if (value is int) return value.toRadixString(16).padLeft(6, '0');
    return value.toString();
  }

  static Map<String, dynamic> normalizeTaskMetadata(Map<String, dynamic> meta) {
    final normalized = Map<String, dynamic>.from(meta);

    normalized['color'] = normalizeColorHex(normalized['color']);
    normalized['textColor'] = normalizeColorHex(normalized['textColor']);
    normalized['stackIndex'] = (normalized['stackIndex'] as num?)?.toInt() ?? 0;
    normalized['load'] = (normalized['load'] as num?)?.toDouble() ?? 1.0;
    normalized['isTimeRangeHighlight'] =
        normalized['isTimeRangeHighlight'] == true;
    normalized['isOverlapIndicator'] = normalized['isOverlapIndicator'] == true;
    normalized['usesWorkCalendar'] = normalized['usesWorkCalendar'] == true;
    normalized['propagatesMoveToChildren'] =
        normalized['propagatesMoveToChildren'] != false;
    normalized['isAutoScheduled'] = normalized['isAutoScheduled'] != false;
    normalized['resizePolicy'] =
        normalizeResizePolicy(normalized['resizePolicy']);

    // UI-only / non-persisted fields — excluded from sync integrity hash.
    normalized['segments'] = null;
    normalized['hasCellBuilder'] = false;

    // Start/end are always serialized as UTC ISO strings in protocol fields.
    normalized['startIsUtc'] = true;
    normalized['endIsUtc'] = true;
    normalized['baselineStartIsUtc'] =
        normalized['baselineStart'] != null ? true : null;
    normalized['baselineEndIsUtc'] =
        normalized['baselineEnd'] != null ? true : null;

    return normalized;
  }

  static Map<String, dynamic> normalizeResourceMetadata(
    Map<String, dynamic> meta, {
    String type = 'person',
  }) {
    final normalized = Map<String, dynamic>.from(meta);
    normalized['ganttType'] = normalized['ganttType'] ?? type;
    normalized['isExpanded'] = normalized['isExpanded'] != false;
    return normalized;
  }

  /// Canonical HLC string for Merkle tree bucketing (handles legacy epoch ints).
  static String merkleHlcKey(String? hlc) {
    if (hlc == null || hlc.isEmpty) return '';
    try {
      return Hlc.parse(hlc).toString();
    } catch (_) {
      return '';
    }
  }

  /// Minute-level bucket prefix used by [MerkleTree.build].
  static String merkleMinutePrefix(String? hlc) {
    final key = merkleHlcKey(hlc);
    if (key.length >= 16 && key.contains('T') && key.contains(':')) {
      return key.substring(0, 16);
    }
    return '0000-00-00T00:00';
  }

  /// Canonical UTC ISO-8601 date for protocol task start/end fields.
  static String formatProtocolDate(dynamic value, {String? fallback}) {
    final defaultFallback =
        fallback ?? DateTime.utc(1970, 1, 1).toIso8601String();
    if (value == null) return defaultFallback;
    if (value is String && value.trim().isEmpty) return defaultFallback;

    DateTime? dt;
    if (value is DateTime) {
      dt = value;
    } else if (value is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    } else if (value is String) {
      dt = DateTime.tryParse(value);
      if (dt == null) {
        final ms = int.tryParse(value);
        if (ms != null) {
          dt = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
        }
      }
    } else if (value is num) {
      dt = DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
    }
    if (dt != null) return dt.toUtc().toIso8601String();
    return defaultFallback;
  }

  static String? formatProtocolDateOrNull(dynamic value) {
    if (value == null) return null;
    return formatProtocolDate(value);
  }
}
