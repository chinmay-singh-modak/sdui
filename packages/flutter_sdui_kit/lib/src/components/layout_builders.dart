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
/// - `scroll` (bool) — wraps in [SingleChildScrollView] to prevent overflow
///
/// Children with `"flex": <int>` in their props are wrapped in [Expanded].
/// Children with `"flex_fit": "loose"` use [Flexible] instead.
Widget columnBuilder(SduiNode node, SduiContext context) {
  final spacing = (node.props['spacing'] as num?)?.toDouble() ?? 0;
  final crossAlign =
      StyleParser.crossAxisAlignment(node.props['cross_alignment'] as String?);
  final mainAlign =
      StyleParser.mainAxisAlignment(node.props['main_alignment'] as String?);
  final shouldScroll = node.props['scroll'] == true;

  final children = _buildFlexChildren(node, context, spacing, isVertical: true);

  Widget column = Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: crossAlign,
    mainAxisAlignment: mainAlign,
    children: children,
  );

  if (shouldScroll) {
    column = SingleChildScrollView(child: column);
  }

  return column;
}

/// Builds a [Row] widget.
///
/// Supported props:
/// - `spacing` (num) — horizontal gap between children
/// - `cross_alignment` (String)
/// - `main_alignment` (String)
/// - `alignment` (String) — shorthand mapped to cross axis
/// - `scroll` (bool) — wraps in horizontal [SingleChildScrollView]
///
/// Children with `"flex": <int>` in their props are wrapped in [Expanded].
/// Children with `"flex_fit": "loose"` use [Flexible] instead.
Widget rowBuilder(SduiNode node, SduiContext context) {
  final spacing = (node.props['spacing'] as num?)?.toDouble() ?? 0;
  final crossAlignKey =
      (node.props['cross_alignment'] ?? node.props['alignment']) as String?;
  final crossAlign = StyleParser.crossAxisAlignment(crossAlignKey);
  final mainAlign =
      StyleParser.mainAxisAlignment(node.props['main_alignment'] as String?);
  final shouldScroll = node.props['scroll'] == true;

  final children = _buildFlexChildren(node, context, spacing, isVertical: false);

  Widget row = Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: crossAlign,
    mainAxisAlignment: mainAlign,
    children: children,
  );

  if (shouldScroll) {
    row = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: row,
    );
  }

  return row;
}

/// Build children with spacing, respecting per-child `flex` / `flex_fit`
/// props. This replaces the old approach of blindly wrapping every child in
/// [Expanded] — which caused RenderFlex overflow when a Column/Row lived
/// inside an unconstrained parent (scroll, another Column, etc.).
///
/// ## How it works
/// - A child whose [SduiNode.props] contains `"flex": <int>` is wrapped in
///   [Expanded] (or [Flexible] if `"flex_fit": "loose"`).
/// - All other children are rendered as-is — no implicit Expanded.
/// - [SizedBox] spacers of the appropriate axis are inserted between items.
List<Widget> _buildFlexChildren(
  SduiNode parent,
  SduiContext context,
  double spacing, {
  required bool isVertical,
}) {
  final nodes = parent.children;
  final result = <Widget>[];

  for (var i = 0; i < nodes.length; i++) {
    Widget child = context.renderChild(nodes[i]);

    // ── Per-child flex wrapping ─────────────────────────────────────
    // Skip nodes whose type is 'expanded' — their builder already wraps.
    final flex = (nodes[i].props['flex'] as num?)?.toInt();
    if (flex != null && flex > 0 && nodes[i].type != 'expanded') {
      final isLoose = nodes[i].props['flex_fit'] == 'loose';
      child = isLoose
          ? Flexible(flex: flex, child: child)
          : Expanded(flex: flex, child: child);
    }

    result.add(child);

    // ── Spacing ─────────────────────────────────────────────────────
    if (spacing > 0 && i < nodes.length - 1) {
      result.add(SizedBox(
        width: isVertical ? 0 : spacing,
        height: isVertical ? spacing : 0,
      ));
    }
  }

  return result;
}
