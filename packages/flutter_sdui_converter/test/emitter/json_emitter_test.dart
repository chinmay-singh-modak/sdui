import 'dart:convert';
import 'dart:io';

import 'package:flutter_sdui_converter/flutter_sdui_converter.dart';
import 'package:test/test.dart';

void main() {
  final schema = SduiSchema(
    schemaVersion: '1.0.0',
    generatedAt: DateTime.utc(2025, 1, 1),
    generatedBy: 'flutter_sdui_converter',
    converterVersion: '1.0.0',
    components: [
      SduiComponent(
        type: 'PrimaryButton',
        props: [SduiProp(name: 'label', type: 'string', required: true)],
        supportsAction: true,
      ),
    ],
  );

  group('JsonEmitter', () {
    test('emit() produces valid JSON', () {
      final emitter = JsonEmitter();
      final output = emitter.emit(schema);
      expect(() => jsonDecode(output), returnsNormally);
    });

    test('emit() output matches schema shape', () {
      final json = jsonDecode(JsonEmitter().emit(schema)) as Map<String, dynamic>;
      expect(json['schemaVersion'], '1.0.0');
      expect(json['generatedBy'], 'flutter_sdui_converter');
      expect((json['components'] as List).length, 1);
    });

    test('emit() output is pretty-printed', () {
      final output = JsonEmitter().emit(schema);
      expect(output, contains('\n'));
      expect(output, contains('  '));
    });

    test('writeToFile() writes JSON to disk', () async {
      final dir = await Directory.systemTemp.createTemp('emitter_test');
      final path = '${dir.path}/out.json';
      await JsonEmitter().writeToFile(schema, path);
      final content = await File(path).readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      expect(json['schemaVersion'], '1.0.0');
      await dir.delete(recursive: true);
    });
  });
}
