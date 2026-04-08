import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sdui_kit/flutter_sdui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'device_presets.dart';
import 'diff_reporter.dart';
import 'font_config.dart';
import 'schema_loader.dart';

/// Registers a golden test group that renders [nativeWidget] alongside its
/// SDUI equivalent and compares them pixel-by-pixel.
///
/// For each entry in [devices] (default: [[SduiDevices.phone]]) a
/// [testWidgets] case is created that:
/// 1. Pins the surface to the device size.
/// 2. Pumps [nativeWidget] and saves a golden at
///    `goldens/{name}_{device}_native.png`.
/// 3. Pumps the [SduiWidget] built from [schemaPath] / [schema] and saves a
///    golden at `goldens/{name}_{device}_sdui.png`.
///
/// Golden paths are relative to the **test file** that calls this function.
///
/// Either [schemaPath] (a file-system path) or [schema] (an inline JSON map)
/// must be provided — not both, not neither.
///
/// [threshold] is the maximum tolerated pixel difference ratio (0.0 – 1.0).
/// The default of `0.01` allows up to 1% of pixels to differ before the test
/// fails. Set to `0.0` for an exact match.
///
/// Example:
/// ```dart
/// void main() {
///   sduiGoldenTest(
///     'login screen',
///     nativeWidget: const LoginScreen(),
///     schemaPath: 'test/fixtures/login.json',
///   );
/// }
/// ```
void sduiGoldenTest(
  String name, {
  required Widget nativeWidget,
  String? schemaPath,
  Map<String, dynamic>? schema,
  List<SduiDevice> devices = const [SduiDevices.phone],
  double threshold = 0.01,
}) {
  assert(
    (schemaPath != null) != (schema != null),
    'sduiGoldenTest: provide exactly one of schemaPath or schema.',
  );

  final safeName = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

  group('sduiGoldenTest: $name', () {
    for (final device in devices) {
      testWidgets('${device.name} — native vs sdui', (tester) async {
        // 1. Pin surface size to device dimensions.
        await tester.binding.setSurfaceSize(device.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // 2. Load the SDUI schema JSON string.
        final String jsonString;
        if (schema != null) {
          jsonString = jsonEncode(schema);
        } else {
          final testSchema = await SduiTestSchema.fromPath(schemaPath!);
          jsonString = testSchema.toJsonString();
        }

        // 3. Install a threshold-aware comparator for this test.
        final savedComparator = goldenFileComparator;
        if (threshold > 0.0 && savedComparator is LocalFileComparator) {
          goldenFileComparator = _ThresholdComparator(
            basedir: savedComparator.basedir,
            threshold: threshold,
            testName: name,
            deviceName: device.name,
          );
        }
        addTearDown(() => goldenFileComparator = savedComparator);

        // 4. Native golden.
        await tester.pumpWidget(
          MaterialApp(
            theme: sduiTestTheme(),
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: nativeWidget),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/${safeName}_${device.name}_native.png'),
        );

        // 5. SDUI golden.
        await tester.pumpWidget(
          MaterialApp(
            theme: sduiTestTheme(),
            debugShowCheckedModeBanner: false,
            home: SduiWidget(json: jsonString),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/${safeName}_${device.name}_sdui.png'),
        );
      });
    }
  });
}

// ── Threshold comparator ──────────────────────────────────────────────────────

/// A [LocalFileComparator] that allows up to [threshold] pixel diff before
/// failing. On first run (no golden file yet) it delegates to the parent to
/// write the golden.
class _ThresholdComparator extends LocalFileComparator {
  final double threshold;
  final String testName;
  final String deviceName;

  _ThresholdComparator({
    required Uri basedir,
    required this.threshold,
    required this.testName,
    required this.deviceName,
  }) : super(basedir);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    // Resolve the golden file path.
    final goldenFile = File.fromUri(basedir.resolve(golden.toString()));

    // First run — write the golden and pass.
    if (!goldenFile.existsSync()) {
      await update(golden, imageBytes);
      return true;
    }

    final masterBytes = await goldenFile.readAsBytes();
    final result = await GoldenFileComparator.compareLists(
        imageBytes, masterBytes);

    if (result.passed) return true;

    if (result.diffPercent <= threshold) return true;

    // Diff exceeds threshold — format a helpful error.
    final message = SduiDiffReporter.failure(
      testName: testName,
      deviceName: deviceName,
      diffPercent: result.diffPercent,
      nativePath: goldenFile.path,
      sduiPath: goldenFile.path,
    );
    throw TestFailure(message);
  }
}
