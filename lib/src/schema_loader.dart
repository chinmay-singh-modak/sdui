import 'dart:convert';
import 'dart:io';

/// Holds an SDUI screen definition and provides it as a JSON string for
/// [SduiWidget].
///
/// Construct from a file path or an inline map:
/// ```dart
/// final schema = await SduiTestSchema.fromPath('test/fixtures/login.json');
/// final schema = SduiTestSchema.fromJson({'screen': 'login', 'body': {...}});
/// ```
class SduiTestSchema {
  final Map<String, dynamic> _json;

  const SduiTestSchema._(this._json);

  /// Load a screen definition from [path] on the file system.
  ///
  /// The file must contain a valid JSON object that [SduiWidget] can parse.
  static Future<SduiTestSchema> fromPath(String path) async {
    final content = await File(path).readAsString();
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException(
          'Expected a JSON object at $path, got ${decoded.runtimeType}');
    }
    return SduiTestSchema._(decoded);
  }

  /// Create a schema from an inline [json] map.
  static SduiTestSchema fromJson(Map<String, dynamic> json) =>
      SduiTestSchema._(Map.unmodifiable(json));

  /// The raw JSON map — for inspection in tests.
  Map<String, dynamic> get json => _json;

  /// Serialised JSON string — the value to pass to [SduiWidget.json].
  String toJsonString() => jsonEncode(_json);
}
