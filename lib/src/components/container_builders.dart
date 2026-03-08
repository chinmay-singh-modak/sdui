import 'package:flutter/widgets.dart';

import '../core/sdui_context.dart';
import '../models/sdui_node.dart';
import '../styles/style_parser.dart';

/// Builds a [Padding] widget.
///
/// Supported props: see [StyleParser.edgeInsetsFromProps].
Widget paddingBuilder(SduiNode node, SduiContext context) {
  final insets = StyleParser.edgeInsetsFromProps(node.props);
  final children = context.renderChildren(node.children);

  return Padding(
    padding: insets,
    child: children.length == 1
        ? children.first
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
  );
}

/// Builds a [SizedBox] widget.
///
/// Supported props:
/// - `width` (num)
/// - `height` (num)
Widget sizedBoxBuilder(SduiNode node, SduiContext context) {
  return SizedBox(
    width: (node.props['width'] as num?)?.toDouble(),
    height: (node.props['height'] as num?)?.toDouble(),
    child: node.children.isNotEmpty
        ? context.renderChild(node.children.first)
        : null,
  );
}

/// Builds a generic container / box.
///
/// Supported props:
/// - `background` (String) — hex colour
/// - `corner_radius` (num)
/// - `elevation` (num) — currently applied as padding visual cue (shadows need Material)
/// - `width` (num)
/// - `height` (num)
/// - `padding` (Map) — see [StyleParser.edgeInsetsFromProps]
Widget containerBuilder(SduiNode node, SduiContext context) {
  final bgColor = node.props.containsKey('background')
      ? StyleParser.colorFromHex(node.props['background'] as String?)
      : null;
  final cornerRadius =
      (node.props['corner_radius'] as num?)?.toDouble() ?? 0;
  final width = (node.props['width'] as num?)?.toDouble();
  final height = (node.props['height'] as num?)?.toDouble();
  final padding = node.props.containsKey('padding')
      ? StyleParser.edgeInsetsFromProps(
          node.props['padding'] as Map<String, dynamic>)
      : null;

  final children = context.renderChildren(node.children);

  Widget child = children.length == 1
      ? children.first
      : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );

  return Container(
    width: width,
    height: height,
    padding: padding,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius:
          cornerRadius > 0 ? BorderRadius.circular(cornerRadius) : null,
    ),
    child: child,
  );
}
