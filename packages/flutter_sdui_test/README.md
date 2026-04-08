# flutter_sdui_test

Golden test utilities for the Flutter SDUI framework. Drop it in `dev_dependencies`, call `sduiGoldenTest()`, and get a side-by-side pixel comparison of your native widget against its SDUI-rendered counterpart — with zero boilerplate.

---

## Installation

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_sdui_test: ^1.0.0
```

---

## Quick start

```dart
import 'package:flutter_sdui_test/flutter_sdui_test.dart';

void main() {
  sduiGoldenTest(
    'login screen',
    nativeWidget: const LoginScreen(),
    schemaPath: 'test/fixtures/login.json',
  );
}
```

```bash
flutter test --update-goldens   # generate golden files
flutter test                    # compare on subsequent runs
```

---

## API

### `sduiGoldenTest`

Registers a `testWidgets` group that renders `nativeWidget` alongside the SDUI equivalent and compares them pixel-by-pixel.

```dart
sduiGoldenTest(
  'screen name',
  nativeWidget: const MyWidget(),

  // Provide exactly one of:
  schemaPath: 'test/fixtures/screen.json',   // file-system path
  schema: {'screen': 'x', 'body': {}},       // inline map

  // Optional
  devices: [SduiDevices.phone, SduiDevices.tablet],
  threshold: 0.01,   // max tolerated pixel diff ratio (0.0 = exact match)
);
```

For each device, two golden files are produced:

```text
test/goldens/
  {test_name}_{device}_native.png
  {test_name}_{device}_sdui.png
```

Paths are relative to the test file.

### Device presets

```dart
SduiDevices.phone    // 390 × 844   (iPhone 14)
SduiDevices.tablet   // 820 × 1180  (iPad Air)
SduiDevices.small    // 360 × 800   (Android compact)
```

Custom device:

```dart
const myDevice = SduiDevice(name: 'desktop', size: Size(1440, 900));
sduiGoldenTest('home', nativeWidget: const HomeScreen(), schema: {...}, devices: [myDevice]);
```

### `SduiTestSchema`

For manual test setup when you need the schema object directly:

```dart
// From a file
final schema = await SduiTestSchema.fromPath('test/fixtures/screen.json');

// From an inline map
final schema = SduiTestSchema.fromJson({'screen': 'x', 'body': {}});

schema.json           // Map<String, dynamic>
schema.toJsonString() // JSON-encoded string
```

### `sduiTestTheme`

Wraps widgets in a `ThemeData` using the deterministic `Ahem` font. This eliminates false-positive golden diffs caused by font-rendering differences between machines or Flutter SDK versions.

`sduiGoldenTest` applies it automatically. Use it directly when pumping widgets manually:

```dart
await tester.pumpWidget(
  MaterialApp(theme: sduiTestTheme(), home: MyWidget()),
);
```

### `loadSduiFonts`

Call in `setUpAll` to use your real app fonts instead of `Ahem`:

```dart
setUpAll(() async {
  await loadSduiFonts();
});
```

Fonts must be declared in your `pubspec.yaml` under `flutter: fonts:`.

### `SduiDiffReporter`

Formats failure output. Used internally by `sduiGoldenTest` but available for custom comparators:

```dart
// Detailed box-drawing failure message
SduiDiffReporter.failure(
  testName: 'login',
  deviceName: 'phone',
  diffPercent: 0.05,
  nativePath: 'goldens/login_phone_native.png',
  sduiPath: 'goldens/login_phone_sdui.png',
);

// One-line summary
SduiDiffReporter.summary(testName: 'login', deviceName: 'phone', diffPercent: 0.05);
```

---

## How threshold comparison works

When `threshold > 0.0`, `sduiGoldenTest` installs a custom `goldenFileComparator` scoped to the test (restored in `addTearDown`). On first run, if no golden exists, it writes the file and passes. On subsequent runs, it computes the pixel diff ratio — if it exceeds `threshold`, the test fails with a detailed message including the file paths and a `--update-goldens` hint.

---

## Part of the flutter_sdui workspace

This package is developed in the [chinmay-singh-modak/sdui_workspace](https://github.com/chinmay-singh-modak/sdui_workspace) monorepo alongside the rest of the toolchain.

| Package | Role | pub.dev |
| ------- | ---- | ------- |
| `flutter_sdui_annotations` | Annotations | [pub.dev/packages/flutter_sdui_annotations](https://pub.dev/packages/flutter_sdui_annotations) |
| `flutter_sdui_converter` | CLI + programmatic converter tool | [pub.dev/packages/flutter_sdui_converter](https://pub.dev/packages/flutter_sdui_converter) |
| `flutter_sdui_test` | Golden test utilities (this package) | [pub.dev/packages/flutter_sdui_test](https://pub.dev/packages/flutter_sdui_test) |
| `flutter_sdui_kit` | SDUI runtime renderer (`SduiWidget`) | [pub.dev/packages/flutter_sdui_kit](https://pub.dev/packages/flutter_sdui_kit) |
