import 'package:flutter/material.dart';

/// Returns a [ThemeData] that uses the deterministic `Ahem` test font.
///
/// Using a fixed font eliminates false-positive golden diffs caused by
/// font-rendering differences between machines or Flutter SDK versions.
///
/// This theme is applied automatically by [sduiGoldenTest]. If you pump
/// widgets manually in your own tests, wrap them with:
/// ```dart
/// MaterialApp(theme: sduiTestTheme(), home: MyWidget())
/// ```
ThemeData sduiTestTheme() => ThemeData(
      fontFamily: 'Ahem',
      useMaterial3: false,
    );

/// Call in [setUpAll] when you want goldens rendered with your real app fonts
/// instead of the default `Ahem` font.
///
/// ```dart
/// setUpAll(() async {
///   await loadSduiFonts();
/// });
/// ```
///
/// Note: custom fonts must be registered in your package's `pubspec.yaml`
/// under `flutter: fonts:` and the test must be run via `flutter test`.
Future<void> loadSduiFonts() async {
  // No-op by default — the test framework loads fonts declared in pubspec.yaml
  // automatically when running under `flutter test`. Override this function in
  // your test setup if you need to load fonts programmatically.
}
