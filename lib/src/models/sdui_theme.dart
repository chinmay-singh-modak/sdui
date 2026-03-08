import 'package:flutter/painting.dart';

/// Theme data sent from the server for a given screen.
///
/// Provides colour overrides that the component builders can reference when
/// constructing widgets.
class SduiTheme {
  final Color primary;
  final Color background;
  final Color text;

  /// Additional colour slots sent from the server that don't map to the
  /// pre-defined fields above.
  final Map<String, Color> extras;

  const SduiTheme({
    required this.primary,
    required this.background,
    required this.text,
    this.extras = const {},
  });

  factory SduiTheme.fromJson(Map<String, dynamic> json) {
    final extras = <String, Color>{};
    for (final entry in json.entries) {
      if (!_reservedKeys.contains(entry.key) && entry.value is String) {
        extras[entry.key] = _parseColor(entry.value as String);
      }
    }

    return SduiTheme(
      primary: _parseColor(json['primary'] as String? ?? '#6C63FF'),
      background: _parseColor(json['background'] as String? ?? '#FFFFFF'),
      text: _parseColor(json['text'] as String? ?? '#000000'),
      extras: extras,
    );
  }

  /// Parses a hex colour string (#RRGGBB or #RRGGBBAA) into a [Color].
  static Color _parseColor(String hex) {
    var h = hex.replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h'; // default opaque
    if (h.length == 8) {
      return Color(int.parse(h, radix: 16));
    }
    return const Color(0xFF000000);
  }

  static const _reservedKeys = {'primary', 'background', 'text'};

  static String _colorToHex(Color color) {
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'primary': _colorToHex(primary),
        'background': _colorToHex(background),
        'text': _colorToHex(text),
      };
}
