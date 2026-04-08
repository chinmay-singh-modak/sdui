/// Formats failure messages for [sduiGoldenTest] mismatches.
class SduiDiffReporter {
  SduiDiffReporter._();

  /// Builds a human-readable failure message for a golden mismatch.
  ///
  /// [testName] is the test description passed to [sduiGoldenTest].
  /// [deviceName] is the [SduiDevice.name] (e.g. "phone").
  /// [diffPercent] is the ratio of differing pixels (0.0 – 1.0).
  /// [nativePath] and [sduiPath] are the golden file paths relative to the test.
  static String failure({
    required String testName,
    required String deviceName,
    required double diffPercent,
    required String nativePath,
    required String sduiPath,
  }) {
    final pct = (diffPercent * 100).toStringAsFixed(2);
    return '''
╔══════════════════════════════════════════════════════════════╗
║  SDUI Golden Test Failed                                     ║
╠══════════════════════════════════════════════════════════════╣
║  Test   : $testName
║  Device : $deviceName
║  Diff   : $pct% of pixels differ
╠══════════════════════════════════════════════════════════════╣
║  Native golden : $nativePath
║  SDUI golden   : $sduiPath
╠══════════════════════════════════════════════════════════════╣
║  To regenerate goldens:
║    flutter test --update-goldens
╚══════════════════════════════════════════════════════════════╝''';
  }

  /// Short one-line summary, used in assertion messages.
  static String summary({
    required String testName,
    required String deviceName,
    required double diffPercent,
  }) {
    final pct = (diffPercent * 100).toStringAsFixed(2);
    return 'sduiGoldenTest "$testName" ($deviceName): $pct% pixel diff — '
        'run flutter test --update-goldens to regenerate';
  }
}
