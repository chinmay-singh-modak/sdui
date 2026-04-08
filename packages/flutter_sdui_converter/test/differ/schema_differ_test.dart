import 'package:flutter_sdui_converter/flutter_sdui_converter.dart';
import 'package:flutter_sdui_converter/src/differ/schema_differ.dart';
import 'package:test/test.dart';

SduiSchema _schema(List<SduiComponent> components) => SduiSchema(
      schemaVersion: '1.0.0',
      generatedAt: DateTime.utc(2025),
      generatedBy: 'flutter_sdui_converter',
      converterVersion: '1.0.0',
      components: components,
    );

SduiComponent _component(
  String type, {
  List<SduiProp> props = const [],
  bool supportsAction = false,
}) =>
    SduiComponent(type: type, props: props, supportsAction: supportsAction);

void main() {
  final differ = SchemaDiffer();

  group('SchemaDiffer — breaking changes', () {
    test('removed component is breaking', () {
      final prev = _schema([_component('Btn')]);
      final curr = _schema([]);
      final diff = differ.diff(prev, curr);
      expect(diff.hasBreakingChanges, true);
      expect(diff.breaking.first.description, contains('Btn'));
    });

    test('removed prop is breaking', () {
      final prev = _schema([
        _component('Btn',
            props: [SduiProp(name: 'label', type: 'string', required: true)])
      ]);
      final curr = _schema([_component('Btn')]);
      final diff = differ.diff(prev, curr);
      expect(diff.hasBreakingChanges, true);
    });

    test('prop type change is breaking', () {
      final prev = _schema([
        _component('Btn',
            props: [SduiProp(name: 'size', type: 'string', required: true)])
      ]);
      final curr = _schema([
        _component('Btn',
            props: [SduiProp(name: 'size', type: 'integer', required: true)])
      ]);
      final diff = differ.diff(prev, curr);
      expect(diff.hasBreakingChanges, true);
      expect(diff.breaking.first.description, contains('string → integer'));
    });

    test('adding required prop is breaking', () {
      final prev = _schema([_component('Btn')]);
      final curr = _schema([
        _component('Btn',
            props: [SduiProp(name: 'size', type: 'integer', required: true)])
      ]);
      final diff = differ.diff(prev, curr);
      expect(diff.hasBreakingChanges, true);
    });

    test('removing action support is breaking', () {
      final prev = _schema([_component('Btn', supportsAction: true)]);
      final curr = _schema([_component('Btn', supportsAction: false)]);
      final diff = differ.diff(prev, curr);
      expect(diff.hasBreakingChanges, true);
    });
  });

  group('SchemaDiffer — non-breaking changes', () {
    test('new component is non-breaking', () {
      final prev = _schema([]);
      final curr = _schema([_component('Btn')]);
      final diff = differ.diff(prev, curr);
      expect(diff.hasBreakingChanges, false);
      expect(diff.nonBreaking, isNotEmpty);
    });

    test('adding optional prop is non-breaking', () {
      final prev = _schema([_component('Btn')]);
      final curr = _schema([
        _component('Btn',
            props: [
              SduiProp(name: 'color', type: 'string', required: false)
            ])
      ]);
      final diff = differ.diff(prev, curr);
      expect(diff.hasBreakingChanges, false);
      expect(diff.nonBreaking, isNotEmpty);
    });

    test('default value added to existing prop is non-breaking', () {
      final prev = _schema([
        _component('Btn',
            props: [SduiProp(name: 'color', type: 'string', required: false)])
      ]);
      final curr = _schema([
        _component('Btn',
            props: [
              SduiProp(
                  name: 'color',
                  type: 'string',
                  required: false,
                  defaultValue: 'blue')
            ])
      ]);
      final diff = differ.diff(prev, curr);
      expect(diff.hasBreakingChanges, false);
    });

    test('adding action support is non-breaking', () {
      final prev = _schema([_component('Btn', supportsAction: false)]);
      final curr = _schema([_component('Btn', supportsAction: true)]);
      final diff = differ.diff(prev, curr);
      expect(diff.hasBreakingChanges, false);
      expect(diff.nonBreaking.any((c) => c.description.contains('action')),
          true);
    });

    test('no changes produces empty diff', () {
      final schema = _schema([
        _component('Btn',
            props: [SduiProp(name: 'label', type: 'string', required: true)])
      ]);
      final diff = differ.diff(schema, schema);
      expect(diff.hasChanges, false);
    });
  });
}
