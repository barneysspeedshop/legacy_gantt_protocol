import 'dart:convert';
import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('RGB integers and hex spellings have one opaque ARGB value', () {
    for (final color in [
      255,
      '255',
      '0000ff',
      '#0000FF',
      'ff0000ff',
      0xff0000ff,
      '4278190335',
    ]) {
      expect(MerkleHashNormalizer.normalizeColorHex(color), 'ff0000ff');
    }
    expect(MerkleHashNormalizer.normalizeColorHex('123456'), 'ff123456');
    expect(MerkleHashNormalizer.normalizeColorHex('#FF0000FF'), 'ff0000ff');
    expect(MerkleHashNormalizer.normalizeColorHex(0x80123456), '80123456');
    expect(MerkleHashNormalizer.normalizeColorHex('00123456'), '00123456');
    expect(MerkleHashNormalizer.normalizeColorHex('80123456'), '80123456');
  });

  test(
    'opaque RGB and ARGB task colors hash identically; alpha remains distinct',
    () {
      ProtocolTask task(String color) => ProtocolTask(
        id: 'colored-task',
        start: '2026-01-01T00:00:00.000Z',
        end: '2026-01-02T00:00:00.000Z',
        metadataJson: jsonEncode({'color': color, 'textColor': color}),
      );
      expect(task('0000ff').contentHash, task('ff0000ff').contentHash);
      expect(task('#123456').contentHash, task('ff123456').contentHash);
      expect(task('000000ff').contentHash, isNot(task('ff0000ff').contentHash));
      expect(task('800000ff').contentHash, isNot(task('ff0000ff').contentHash));
    },
  );
}
