import 'package:flutter_sdui_converter/flutter_sdui_converter.dart';
import 'package:flutter_sdui_converter/src/config/sdui_config.dart';
import 'package:flutter_sdui_converter/src/parser/raw_component.dart';
import 'package:flutter_sdui_converter/src/transformer/schema_transformer.dart';
import 'package:test/test.dart';

void main() {
  final transformer = SchemaTransformer();
  const version = '1.0.0';

  group('SchemaTransformer', () {
    test('maps known Dart types to SDUI types', () {
      final raw = [
        RawComponent(
          widgetClassName: 'Btn',
          sduiName: 'Btn',
          props: [
            RawProp(fieldName: 'label', dartType: 'String', isNullable: false),
            RawProp(fieldName: 'count', dartType: 'int', isNullable: false),
            RawProp(fieldName: 'amount', dartType: 'double', isNullable: false),
            RawProp(fieldName: 'enabled', dartType: 'bool', isNullable: false),
            RawProp(fieldName: 'color', dartType: 'Color', isNullable: false),
            RawProp(
                fieldName: 'items',
                dartType: 'List<String>',
                isNullable: false),
            RawProp(
                fieldName: 'data',
                dartType: 'Map<String, dynamic>',
                isNullable: false),
          ],
          actions: [],
          sourceFile: 'test.dart',
        )
      ];

      final result = transformer.transform(raw, SduiConfig(), version);
      expect(result.isSuccess, true);
      result.fold(
        onSuccess: (schema) {
          final props = schema.components.first.props;
          expect(props[0].type, 'string');
          expect(props[1].type, 'integer');
          expect(props[2].type, 'number');
          expect(props[3].type, 'boolean');
          expect(props[4].type, 'color');
          expect(props[5].type, 'array');
          expect(props[6].type, 'object');
        },
        onError: (_) => fail('Expected success'),
      );
    });

    test('required=true when non-nullable and no default', () {
      final raw = [
        RawComponent(
          widgetClassName: 'Btn',
          sduiName: 'Btn',
          props: [
            RawProp(
                fieldName: 'label', dartType: 'String', isNullable: false),
          ],
          actions: [],
          sourceFile: 'test.dart',
        )
      ];

      transformer.transform(raw, SduiConfig(), version).fold(
        onSuccess: (s) => expect(s.components.first.props.first.required, true),
        onError: (_) => fail('Expected success'),
      );
    });

    test('required=false when nullable', () {
      final raw = [
        RawComponent(
          widgetClassName: 'Btn',
          sduiName: 'Btn',
          props: [
            RawProp(
                fieldName: 'label', dartType: 'String', isNullable: true),
          ],
          actions: [],
          sourceFile: 'test.dart',
        )
      ];

      transformer.transform(raw, SduiConfig(), version).fold(
        onSuccess: (s) =>
            expect(s.components.first.props.first.required, false),
        onError: (_) => fail('Expected success'),
      );
    });

    test('required=false when has default', () {
      final raw = [
        RawComponent(
          widgetClassName: 'Btn',
          sduiName: 'Btn',
          props: [
            RawProp(
                fieldName: 'color',
                dartType: 'String',
                isNullable: false,
                defaultValue: 'blue',
                hasDefaultValue: true),
          ],
          actions: [],
          sourceFile: 'test.dart',
        )
      ];

      transformer.transform(raw, SduiConfig(), version).fold(
        onSuccess: (s) {
          expect(s.components.first.props.first.required, false);
          expect(s.components.first.props.first.defaultValue, 'blue');
        },
        onError: (_) => fail('Expected success'),
      );
    });

    test('unknown type falls back to "any" in non-strict mode', () {
      final raw = [
        RawComponent(
          widgetClassName: 'Btn',
          sduiName: 'Btn',
          props: [
            RawProp(
                fieldName: 'widget',
                dartType: 'Widget',
                isNullable: false),
          ],
          actions: [],
          sourceFile: 'test.dart',
        )
      ];

      transformer.transform(raw, SduiConfig(), version).fold(
        onSuccess: (s) =>
            expect(s.components.first.props.first.type, 'any'),
        onError: (_) => fail('Expected success in non-strict mode'),
      );
    });

    test('unknown type returns error in strict mode', () {
      final raw = [
        RawComponent(
          widgetClassName: 'Btn',
          sduiName: 'Btn',
          props: [
            RawProp(
                fieldName: 'widget',
                dartType: 'Widget',
                isNullable: false),
          ],
          actions: [],
          sourceFile: 'test.dart',
        )
      ];

      final strictConfig = SduiConfig(
          flags: const FeatureFlags(strictMode: true));

      transformer.transform(raw, strictConfig, version).fold(
        onSuccess: (_) => fail('Expected failure in strict mode'),
        onError: (errors) => expect(errors, isNotEmpty),
      );
    });

    test('VoidCallback props set supportsAction=true', () {
      final raw = [
        RawComponent(
          widgetClassName: 'Btn',
          sduiName: 'Btn',
          props: [
            RawProp(
                fieldName: 'onTap',
                dartType: 'VoidCallback',
                isNullable: true),
          ],
          actions: [],
          sourceFile: 'test.dart',
        )
      ];

      transformer.transform(raw, SduiConfig(), version).fold(
        onSuccess: (s) {
          expect(s.components.first.props, isEmpty);
          expect(s.components.first.supportsAction, true);
        },
        onError: (_) => fail('Expected success'),
      );
    });

    test('@SduiAction annotations set supportsAction=true', () {
      final raw = [
        RawComponent(
          widgetClassName: 'Btn',
          sduiName: 'Btn',
          props: [],
          actions: [RawAction(fieldName: 'onTap')],
          sourceFile: 'test.dart',
        )
      ];

      transformer.transform(raw, SduiConfig(), version).fold(
        onSuccess: (s) => expect(s.components.first.supportsAction, true),
        onError: (_) => fail('Expected success'),
      );
    });

    test('no actions sets supportsAction=false', () {
      final raw = [
        RawComponent(
          widgetClassName: 'Label',
          sduiName: 'Label',
          props: [
            RawProp(fieldName: 'text', dartType: 'String', isNullable: false),
          ],
          actions: [],
          sourceFile: 'test.dart',
        )
      ];

      transformer.transform(raw, SduiConfig(), version).fold(
        onSuccess: (s) => expect(s.components.first.supportsAction, false),
        onError: (_) => fail('Expected success'),
      );
    });
  });
}
