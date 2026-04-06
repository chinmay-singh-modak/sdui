import 'package:flutter/material.dart';
import 'package:flutter_sdui_test/flutter_sdui_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── SduiDevices ─────────────────────────────────────────────────────────────

  group('SduiDevices', () {
    test('phone preset has correct dimensions', () {
      expect(SduiDevices.phone.size.width, 390);
      expect(SduiDevices.phone.size.height, 844);
      expect(SduiDevices.phone.name, 'phone');
    });

    test('tablet preset has correct dimensions', () {
      expect(SduiDevices.tablet.size.width, 820);
      expect(SduiDevices.tablet.size.height, 1180);
      expect(SduiDevices.tablet.name, 'tablet');
    });

    test('small preset has correct dimensions', () {
      expect(SduiDevices.small.size.width, 360);
      expect(SduiDevices.small.size.height, 800);
      expect(SduiDevices.small.name, 'small');
    });
  });

  // ── SduiTestSchema ───────────────────────────────────────────────────────────

  group('SduiTestSchema', () {
    test('fromJson round-trips to JSON string', () {
      final schema = SduiTestSchema.fromJson({
        'screen': 'test',
        'version': 1,
        'body': {'type': 'text', 'props': {'content': 'Hello'}},
      });

      expect(schema.json['screen'], 'test');
      expect(schema.toJsonString(), contains('"screen"'));
      expect(schema.toJsonString(), contains('"test"'));
    });

    test('toJsonString produces valid JSON', () {
      final schema = SduiTestSchema.fromJson({'screen': 'x', 'body': {}});
      expect(() => schema.toJsonString(), returnsNormally);
    });
  });

  // ── SduiDiffReporter ─────────────────────────────────────────────────────────

  group('SduiDiffReporter', () {
    test('failure message contains test name, device, and diff', () {
      final msg = SduiDiffReporter.failure(
        testName: 'login',
        deviceName: 'phone',
        diffPercent: 0.05,
        nativePath: 'goldens/login_phone_native.png',
        sduiPath: 'goldens/login_phone_sdui.png',
      );
      expect(msg, contains('login'));
      expect(msg, contains('phone'));
      expect(msg, contains('5.00%'));
      expect(msg, contains('--update-goldens'));
    });

    test('summary message is concise', () {
      final msg = SduiDiffReporter.summary(
        testName: 'home',
        deviceName: 'tablet',
        diffPercent: 0.02,
      );
      expect(msg, contains('home'));
      expect(msg, contains('tablet'));
      expect(msg, contains('2.00%'));
    });
  });

  // ── sduiTestTheme ────────────────────────────────────────────────────────────

  group('sduiTestTheme', () {
    test('applies Ahem font family', () {
      final theme = sduiTestTheme();
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Ahem');
    });
  });

  // ── sduiGoldenTest assertion guards ──────────────────────────────────────────

  test('sduiGoldenTest asserts when neither schemaPath nor schema is provided',
      () {
    expect(
      () => sduiGoldenTest(
        'bad call',
        nativeWidget: const SizedBox(),
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('sduiGoldenTest asserts when both schemaPath and schema are provided',
      () {
    expect(
      () => sduiGoldenTest(
        'bad call',
        nativeWidget: const SizedBox(),
        schemaPath: 'foo.json',
        schema: {'screen': 'x', 'body': {}},
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
