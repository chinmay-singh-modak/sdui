import 'package:flutter/rendering.dart';

/// Utility helpers for parsing style-related values from JSON props.
class StyleParser {
  StyleParser._();

  /// Parse a hex colour string (#RGB, #RRGGBB, #RRGGBBAA) into a [Color].
  /// Returns [fallback] when the string is null or malformed.
  static Color colorFromHex(String? hex, [Color fallback = const Color(0xFF000000)]) {
    if (hex == null || hex.isEmpty) return fallback;
    var h = hex.replaceFirst('#', '');
    if (h.length == 3) {
      h = h.split('').map((c) => '$c$c').join();
    }
    if (h.length == 6) h = 'FF$h';
    if (h.length == 8) {
      final value = int.tryParse(h, radix: 16);
      if (value != null) return Color(value);
    }
    return fallback;
  }

  /// Parse [EdgeInsets] from a props map.
  ///
  /// Supports:
  /// - `"all"` → uniform insets
  /// - `"horizontal"` / `"vertical"` → symmetric insets
  /// - `"left"`, `"right"`, `"top"`, `"bottom"` → individual insets
  static EdgeInsets edgeInsetsFromProps(Map<String, dynamic> props) {
    if (props.containsKey('all')) {
      return EdgeInsets.all((props['all'] as num).toDouble());
    }
    final h = (props['horizontal'] as num?)?.toDouble() ?? 0;
    final v = (props['vertical'] as num?)?.toDouble() ?? 0;
    final l = (props['left'] as num?)?.toDouble() ?? h;
    final r = (props['right'] as num?)?.toDouble() ?? h;
    final t = (props['top'] as num?)?.toDouble() ?? v;
    final b = (props['bottom'] as num?)?.toDouble() ?? v;
    return EdgeInsets.only(left: l, right: r, top: t, bottom: b);
  }

  /// Map a style name token (e.g. "heading", "body") to a [TextStyle].
  ///
  /// Override or extend this to customise font mapping.
  static TextStyle textStyleFromName(String? name) {
    return switch (name) {
      'heading' => const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      'subheading' => const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      'body' => const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      'caption' => const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
      _ => const TextStyle(fontSize: 14),
    };
  }

  /// Resolve a [CrossAxisAlignment] from a string token.
  static CrossAxisAlignment crossAxisAlignment(String? value) {
    return switch (value) {
      'start' => CrossAxisAlignment.start,
      'end' => CrossAxisAlignment.end,
      'center' => CrossAxisAlignment.center,
      'stretch' => CrossAxisAlignment.stretch,
      _ => CrossAxisAlignment.start,
    };
  }

  /// Resolve a [MainAxisAlignment] from a string token.
  static MainAxisAlignment mainAxisAlignment(String? value) {
    return switch (value) {
      'start' => MainAxisAlignment.start,
      'end' => MainAxisAlignment.end,
      'center' => MainAxisAlignment.center,
      'spaceBetween' => MainAxisAlignment.spaceBetween,
      'spaceAround' => MainAxisAlignment.spaceAround,
      'spaceEvenly' => MainAxisAlignment.spaceEvenly,
      _ => MainAxisAlignment.start,
    };
  }

  /// Parse a border radius from a numeric value or props map.
  static BorderRadius borderRadius(dynamic value) {
    if (value is num) {
      return BorderRadius.circular(value.toDouble());
    }
    return BorderRadius.zero;
  }
}
