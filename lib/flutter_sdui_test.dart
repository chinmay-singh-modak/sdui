/// Testing utilities for the Flutter SDUI framework.
///
/// Drop this in `dev_dependencies`, then call [sduiGoldenTest] from your test
/// files to compare native widgets against their SDUI-rendered counterparts.
///
/// Quick start:
/// ```dart
/// import 'package:flutter_sdui_test/flutter_sdui_test.dart';
///
/// void main() {
///   sduiGoldenTest(
///     'login screen',
///     nativeWidget: const LoginScreen(),
///     schemaPath: 'test/fixtures/login.json',
///   );
/// }
/// ```
library;

export 'src/golden_test.dart' show sduiGoldenTest;
export 'src/device_presets.dart' show SduiDevice, SduiDevices;
export 'src/schema_loader.dart' show SduiTestSchema;
export 'src/font_config.dart' show sduiTestTheme, loadSduiFonts;
export 'src/diff_reporter.dart' show SduiDiffReporter;
