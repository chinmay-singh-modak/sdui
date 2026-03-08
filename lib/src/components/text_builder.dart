import 'package:flutter/widgets.dart';

import '../core/sdui_context.dart';
import '../models/sdui_node.dart';
import '../styles/style_parser.dart';

/// Builds a [Text] widget from an [SduiNode].
///
/// Supported props:
/// - `content` (String) — the text to display
/// - `style` (String) — one of "heading", "subheading", "body", "caption"
/// - `color` (String) — hex colour override
/// - `max_lines` (int) — max lines before truncation
/// - `text_align` (String) — "left", "center", "right"
Widget textBuilder(SduiNode node, SduiContext context) {
  final content = node.props['content'] as String? ?? '';
  final styleName = node.props['style'] as String?;
  final colorHex = node.props['color'] as String?;
  final maxLines = node.props['max_lines'] as int?;
  final textAlign = _parseTextAlign(node.props['text_align'] as String?);

  var textStyle = StyleParser.textStyleFromName(styleName);
  if (colorHex != null) {
    textStyle = textStyle.copyWith(color: StyleParser.colorFromHex(colorHex));
  }

  return Text(
    content,
    style: textStyle,
    maxLines: maxLines,
    overflow: maxLines != null ? TextOverflow.ellipsis : null,
    textAlign: textAlign,
  );
}

TextAlign? _parseTextAlign(String? value) {
  return switch (value) {
    'left' => TextAlign.left,
    'center' => TextAlign.center,
    'right' => TextAlign.right,
    _ => null,
  };
}
