# Changelog

## [1.0.1](https://github.com/chinmay-singh-modak/sdui/compare/flutter_sdui_test-v1.0.0...flutter_sdui_test-v1.0.1) (2026-04-08)


### Bug Fixes

* **flutter_sdui_test:** update installation URL and add monorepo workspace links ([ee42ac1](https://github.com/chinmay-singh-modak/sdui/commit/ee42ac12bdbbcf57865c47eb41f5e79e6c271f43))

## 1.0.0

* Initial release of `flutter_sdui_test` — golden test utilities for comparing native Flutter widgets against their SDUI-rendered equivalents.
* `sduiGoldenTest()` — registers a `testWidgets` group per device that captures `{name}_{device}_native.png` and `{name}_{device}_sdui.png` golden files side-by-side.
* `SduiDevices` presets: `phone` (390×844 iPhone 14), `tablet` (820×1180 iPad Air), `small` (360×800 Android compact).
* `SduiTestSchema` — loads a JSON schema from a file path (`fromPath`) or an inline map (`fromJson`).
* `sduiTestTheme` / `loadSduiFonts` — wraps pumped widgets with the `Ahem` test font to prevent false positives from font rendering differences.
* `SduiDiffReporter` — formats pixel-diff failure output with per-pixel statistics.
* Configurable `threshold` parameter (0.0–1.0, default `0.01`) for tolerating minor rendering differences.
