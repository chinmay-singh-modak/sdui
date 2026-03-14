import 'package:flutter/widgets.dart';

import '../core/sdui_context.dart';
import '../models/sdui_node.dart';
import '../styles/style_parser.dart';

/// Builds a tappable button widget.
///
/// Supported props:
/// - `label` (String) — button text
/// - `variant` (String) — "primary", "outline", "text"
/// - `full_width` (bool)
/// - `background` (String) — hex colour override
/// - `text_color` (String) — hex colour override for the label
/// - `corner_radius` (num)
Widget buttonBuilder(SduiNode node, SduiContext context) {
  final label = node.props['label'] as String? ?? '';
  final variant = node.props['variant'] as String? ?? 'primary';
  final fullWidth = node.props['full_width'] as bool? ?? false;
  final cornerRadius =
      (node.props['corner_radius'] as num?)?.toDouble() ?? 8;

  // Resolve colours based on theme + variant.
  final themePrimary = context.theme?.primary ?? const Color(0xFF6C63FF);
  final Color bgColor;
  final Color textColor;
  final BoxBorder? border;

  switch (variant) {
    case 'outline':
      bgColor = const Color(0x00000000);
      textColor = themePrimary;
      border = Border.all(color: themePrimary);
      break;
    case 'text':
      bgColor = const Color(0x00000000);
      textColor = themePrimary;
      border = null;
      break;
    case 'primary':
    default:
      bgColor = node.props.containsKey('background')
          ? StyleParser.colorFromHex(node.props['background'] as String?)
          : themePrimary;
      textColor = node.props.containsKey('text_color')
          ? StyleParser.colorFromHex(node.props['text_color'] as String?)
          : const Color(0xFFFFFFFF);
      border = null;
  }

  Widget btn = Builder(
    builder: (buildContext) => GestureDetector(
      onTap: node.action != null
          ? () => context.onAction?.call(buildContext, node.action!)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: border,
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
        // Align.center sizes itself to its parent but doesn't force an
        // infinite intrinsic width the way Center does — safe inside
        // unconstrained parents (Row, ScrollView, etc.).
        child: Align(
          alignment: Alignment.center,
          widthFactor: fullWidth ? null : 1.0,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ),
  );

  return btn;
}
