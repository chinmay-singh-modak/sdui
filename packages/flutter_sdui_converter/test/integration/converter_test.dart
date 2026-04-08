import 'package:flutter_sdui_converter/flutter_sdui_converter.dart';
import 'package:test/test.dart';

const _fixtureProject = 'test/fixtures/sample_project';

void main() {
  group('SduiConverter integration', () {
    test('converts sample project to schema', () async {
      final result = await SduiConverter.convert(
        projectPath: _fixtureProject,
        config: SduiConfig(
          scan: ScanConfig(include: ['lib/components']),
        ),
      );

      expect(result.isSuccess, true);
      result.fold(
        onSuccess: (schema) {
          expect(schema.generatedBy, 'flutter_sdui_converter');
          expect(schema.components.length, 2);

          final types = schema.components.map((c) => c.type).toSet();
          expect(types, containsAll(['PrimaryButton', 'IconButton']));
        },
        onError: (errors) => fail('Expected success, got: $errors'),
      );
    });

    test('PrimaryButton has correct props and action', () async {
      final result = await SduiConverter.convert(
        projectPath: _fixtureProject,
        config: SduiConfig(
          scan: ScanConfig(include: ['lib/components']),
        ),
      );

      result.fold(
        onSuccess: (schema) {
          final btn = schema.components
              .firstWhere((c) => c.type == 'PrimaryButton');

          final label =
              btn.props.firstWhere((p) => p.name == 'label');
          expect(label.type, 'string');
          expect(label.required, true);

          final color =
              btn.props.firstWhere((p) => p.name == 'color');
          expect(color.type, 'string');
          expect(color.required, false);
          expect(color.defaultValue, 'blue');

          expect(btn.supportsAction, true);
        },
        onError: (errors) => fail('Expected success, got: $errors'),
      );
    });

    test('non-annotated files are excluded', () async {
      final result = await SduiConverter.convert(
        projectPath: _fixtureProject,
        config: SduiConfig(scan: ScanConfig(include: ['lib/'])),
      );

      result.fold(
        onSuccess: (schema) {
          final types = schema.components.map((c) => c.type).toSet();
          expect(types.contains('NotAComponent'), false);
        },
        onError: (errors) => fail('Expected success, got: $errors'),
      );
    });

    test('schema JSON round-trips correctly', () async {
      final result = await SduiConverter.convert(
        projectPath: _fixtureProject,
        config: SduiConfig(
          scan: ScanConfig(include: ['lib/components']),
        ),
      );

      result.fold(
        onSuccess: (schema) {
          final restored = SduiSchema.fromJson(schema.toJson());
          expect(restored.components.length, schema.components.length);
          expect(
              restored.components.map((c) => c.type).toSet(),
              schema.components.map((c) => c.type).toSet());
        },
        onError: (errors) => fail('Expected success, got: $errors'),
      );
    });

    test('differ detects breaking change', () async {
      final prev = SduiSchema(
        schemaVersion: '1.0.0',
        generatedAt: DateTime.utc(2025),
        generatedBy: 'flutter_sdui_converter',
        converterVersion: '1.0.0',
        components: [
          SduiComponent(
            type: 'PrimaryButton',
            props: [
              SduiProp(name: 'label', type: 'string', required: true),
              SduiProp(name: 'size', type: 'string', required: true),
            ],
          ),
        ],
      );

      final result = await SduiConverter.convert(
        projectPath: _fixtureProject,
        config: SduiConfig(
          scan: ScanConfig(include: ['lib/components']),
        ),
        previousSchema: prev,
      );

      result.fold(
        onSuccess: (schema) {
          final diff = schema.diff;
          expect(diff, isNotNull);
          expect(diff!.hasBreakingChanges, true);
        },
        onError: (errors) => fail('Expected success, got: $errors'),
      );
    });
  });
}
