import 'package:flutter/widgets.dart';

import '../core/sdui_context.dart';
import '../models/sdui_node.dart';
import '../styles/style_parser.dart';

/// Builds a [Column] widget.
///
/// Supported props:
/// - `spacing` (num) — vertical gap between children
/// - `cross_alignment` (String) — "start", "center", "end", "stretch"
/// - `main_alignment` (String) — "start", "center", "end", "spaceBetween", …
Widget columnBuilder(SduiNode node, SduiContext context) {
  final spacing = (node.props['spacing'] as num?)?.toDouble() ?? 0;
  final crossAlign =
      StyleParser.crossAxisAlignment(node.props['cross_alignment'] as String?);
  final mainAlign =
      StyleParser.mainAxisAlignment(node.props['main_alignment'] as String?);

  final children = context.renderChildren(node.children);

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: crossAlign,
    mainAxisAlignment: mainAlign,
    children: _withSpacing(children, spacing),
  );
}

/// Builds a [Row] widget.
///
/// Supported props:
/// - `spacing` (num) — horizontal gap between children
/// - `cross_alignment` (String)
/// - `main_alignment` (String)
/// - `alignment` (String) — shorthand mapped to cross axis
Widget rowBuilder(SduiNode node, SduiContext context) {
  final spacing = (node.props['spacing'] as num?)?.toDouble() ?? 0;
  final crossAlignKey =
      (node.props['cross_alignment'] ?? node.props['alignment']) as String?;
  final crossAlign = StyleParser.crossAxisAlignment(crossAlignKey);
  final mainAlign =
      StyleParser.mainAxisAlignment(node.props['main_alignment'] as String?);

  final children = context.renderChildren(node.children);

  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: crossAlign,
    mainAxisAlignment: mainAlign,
    children: _withSpacing(children, spacing),
  );
}

/// Insert [SizedBox] spacers between widgets.
List<Widget> _withSpacing(List<Widget> widgets, double spacing) {
  if (spacing <= 0 || widgets.length <= 1) return widgets;
  final spaced = <Widget>[];
  for (var i = 0; i < widgets.length; i++) {
    spaced.add(Expanded(child: widgets[i]));
    if (i < widgets.length - 1) {
      spaced.add(SizedBox(width: spacing, height: spacing));
    }
  }
  return spaced;
}
