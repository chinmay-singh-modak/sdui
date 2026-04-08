import 'dart:ui';

/// A device configuration used to pin the surface size in golden tests.
class SduiDevice {
  /// Human-readable name used in golden file names (e.g. "phone").
  final String name;

  /// Logical pixel size to apply via [WidgetTester.binding.setSurfaceSize].
  final Size size;

  const SduiDevice({required this.name, required this.size});
}

/// Pre-defined device presets for common screen sizes.
///
/// Pass one or more to the [devices] parameter of [sduiGoldenTest]:
/// ```dart
/// sduiGoldenTest('home', nativeWidget: HomeScreen(),
///     schema: json, devices: [SduiDevices.phone, SduiDevices.tablet]);
/// ```
class SduiDevices {
  SduiDevices._();

  /// 390×844 — iPhone 14 logical resolution.
  static const phone = SduiDevice(name: 'phone', size: Size(390, 844));

  /// 820×1180 — iPad Air logical resolution.
  static const tablet = SduiDevice(name: 'tablet', size: Size(820, 1180));

  /// 360×800 — Android compact (e.g. Pixel 4a).
  static const small = SduiDevice(name: 'small', size: Size(360, 800));
}
