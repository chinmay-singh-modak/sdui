import 'package:flutter_sdui_annotations/flutter_sdui_annotations.dart';
import 'package:test/test.dart';

void main() {
  group('SduiComponent', () {
    test('stores name', () {
      const annotation = SduiComponent(name: 'PrimaryButton');
      expect(annotation.name, 'PrimaryButton');
    });

    test('is const constructible', () {
      const a1 = SduiComponent(name: 'Foo');
      const a2 = SduiComponent(name: 'Foo');
      expect(identical(a1, a2), isTrue);
    });
  });

  group('SduiProp', () {
    test('defaultValue is null when not provided', () {
      const annotation = SduiProp();
      expect(annotation.defaultValue, isNull);
    });

    test('stores defaultValue when provided', () {
      const annotation = SduiProp(defaultValue: 'blue');
      expect(annotation.defaultValue, 'blue');
    });

    test('works with non-string default values', () {
      const intProp = SduiProp(defaultValue: 42);
      const boolProp = SduiProp(defaultValue: true);
      expect(intProp.defaultValue, 42);
      expect(boolProp.defaultValue, true);
    });
  });

  group('SduiAction', () {
    test('is const constructible', () {
      const a1 = SduiAction();
      const a2 = SduiAction();
      expect(identical(a1, a2), isTrue);
    });
  });
}
