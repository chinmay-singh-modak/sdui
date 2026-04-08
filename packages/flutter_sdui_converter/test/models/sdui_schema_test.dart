import 'package:flutter_sdui_converter/flutter_sdui_converter.dart';
import 'package:test/test.dart';

void main() {
  group('SduiSchema round-trip', () {
    final schema = SduiSchema(
      schemaVersion: '1.0.0',
      generatedAt: DateTime.utc(2025, 1, 1, 12),
      generatedBy: 'flutter_sdui_converter',
      converterVersion: '1.0.0',
      components: [
        SduiComponent(
          type: 'PrimaryButton',
          props: [
            SduiProp(name: 'label', type: 'string', required: true),
            SduiProp(
                name: 'color',
                type: 'string',
                required: false,
                defaultValue: 'blue'),
          ],
          supportsAction: true,
        ),
      ],
    );

    test('toJson contains expected keys', () {
      final json = schema.toJson();
      expect(json['schemaVersion'], '1.0.0');
      expect(json['generatedBy'], 'flutter_sdui_converter');
      expect(json['converterVersion'], '1.0.0');
      expect((json['components'] as List).length, 1);
    });

    test('fromJson restores schema', () {
      final json = schema.toJson();
      final restored = SduiSchema.fromJson(json);
      expect(restored.schemaVersion, schema.schemaVersion);
      expect(restored.generatedBy, schema.generatedBy);
      expect(restored.components.length, 1);
      expect(restored.components.first.type, 'PrimaryButton');
    });

    test('component uses "type" key in JSON', () {
      final json = schema.toJson();
      final comp = (json['components'] as List).first as Map<String, dynamic>;
      expect(comp['type'], 'PrimaryButton');
      expect(comp.containsKey('name'), false);
    });

    test('prop required/optional serializes', () {
      final json = schema.toJson();
      final props = (json['components'] as List).first['props'] as List;
      expect(props.first['required'], true);
      expect(props.last['required'], false);
      expect(props.last['default'], 'blue');
    });

    test('prop without default omits default key', () {
      final json = schema.toJson();
      final props = (json['components'] as List).first['props'] as List;
      expect(props.first.containsKey('default'), false);
    });

    test('supportsAction serializes correctly', () {
      final json = schema.toJson();
      final comp = (json['components'] as List).first as Map<String, dynamic>;
      expect(comp['supportsAction'], true);
    });

    test('supportsAction=false when no actions', () {
      final noAction = SduiComponent(
        type: 'Label',
        props: [SduiProp(name: 'text', type: 'string', required: true)],
      );
      expect(noAction.toJson()['supportsAction'], false);
    });
  });
}
