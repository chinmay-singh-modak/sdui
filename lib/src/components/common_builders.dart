import 'package:flutter/widgets.dart';

import '../core/sdui_context.dart';
import '../models/sdui_node.dart';
import '../styles/style_parser.dart';

/// Builds a scrollable container.
///
/// Supported props:
/// - `direction` (String) — "horizontal" or "vertical" (default)
Widget scrollBuilder(SduiNode node, SduiContext context) {
  final isHorizontal = node.props['direction'] == 'horizontal';
  final children = context.renderChildren(node.children);

  return SingleChildScrollView(
    scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
    child: isHorizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
  );
}

/// Builds a horizontal or vertical scrollable list.
///
/// Supported props:
/// - `direction` (String) — "horizontal" or "vertical" (default)
/// - `spacing` (num) — gap between items
/// - `padding` (Map) — outer padding
Widget listBuilder(SduiNode node, SduiContext context) {
  final isHorizontal = node.props['direction'] == 'horizontal';
  final spacing = (node.props['spacing'] as num?)?.toDouble() ?? 0;
  final padding = node.props.containsKey('padding')
      ? StyleParser.edgeInsetsFromProps(
          node.props['padding'] as Map<String, dynamic>)
      : EdgeInsets.zero;

  final children = context.renderChildren(node.children);
  final spaced = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    spaced.add(children[i]);
    if (spacing > 0 && i < children.length - 1) {
      spaced.add(SizedBox(
        width: isHorizontal ? spacing : 0,
        height: isHorizontal ? 0 : spacing,
      ));
    }
  }

  return SingleChildScrollView(
    scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
    padding: padding,
    child: isHorizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: spaced)
        : Column(mainAxisSize: MainAxisSize.min, children: spaced),
  );
}

/// Builds a card container.
///
/// Supported props:
/// - `corner_radius` (num)
/// - `background` (String) — hex colour
/// - `elevation` (num)
/// - `width` (num)
/// - `padding` (Map)
Widget cardBuilder(SduiNode node, SduiContext context) {
  final cornerRadius =
      (node.props['corner_radius'] as num?)?.toDouble() ?? 0;
  final bgColor = node.props.containsKey('background')
      ? StyleParser.colorFromHex(node.props['background'] as String?)
      : const Color(0xFFFFFFFF);
  final width = (node.props['width'] as num?)?.toDouble();
  final elevation = (node.props['elevation'] as num?)?.toDouble() ?? 0;

  final children = context.renderChildren(node.children);

  Widget child = children.length == 1
      ? children.first
      : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );

  Widget card = Container(
    width: width,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius:
          cornerRadius > 0 ? BorderRadius.circular(cornerRadius) : null,
      boxShadow: elevation > 0
          ? [
              BoxShadow(
                color: const Color(0x29000000),
                blurRadius: elevation * 2,
                offset: Offset(0, elevation),
              ),
            ]
          : null,
    ),
    child: cornerRadius > 0
        ? ClipRRect(
            borderRadius: BorderRadius.circular(cornerRadius),
            child: child,
          )
        : child,
  );

  // Wrap with GestureDetector if an action is attached.
  if (node.action != null) {
    card = GestureDetector(
      onTap: () => context.onAction?.call(node.action!),
      child: card,
    );
  }

  return card;
}

/// Builds a horizontal divider.
///
/// Supported props:
/// - `color` (String) — hex colour
/// - `thickness` (num)
Widget dividerBuilder(SduiNode node, SduiContext context) {
  final color = StyleParser.colorFromHex(
      node.props['color'] as String?, const Color(0xFFE0E0E0));
  final thickness = (node.props['thickness'] as num?)?.toDouble() ?? 1;

  return Container(
    height: thickness,
    color: color,
  );
}

/// Builds an icon placeholder (uses Unicode / text since flutter/widgets
/// doesn't include Material Icons by default).
///
/// Supported props:
/// - `name` (String) — icon name (for future Material/Cupertino lookup)
/// - `size` (num)
/// - `color` (String)
Widget iconBuilder(SduiNode node, SduiContext context) {
  final size = (node.props['size'] as num?)?.toDouble() ?? 24;
  final color = StyleParser.colorFromHex(node.props['color'] as String?);
  final name = node.props['name'] as String? ?? 'star';

  // Placeholder: render the icon name as text. When you add Material
  // dependency later, replace this with Icon(iconDataMap[name]).
  return SizedBox(
    width: size,
    height: size,
    child: Center(
      child: Text(
        _iconFallbackChar(name),
        style: TextStyle(fontSize: size * 0.8, color: color),
      ),
    ),
  );
}

String _iconFallbackChar(String name) {
  // Simple fallback map — extend as needed or swap for Material Icons.
  return switch (name) {
    'local_offer' => '🏷️',
    'star' => '⭐',
    'favorite' => '❤️',
    'home' => '🏠',
    'search' => '🔍',
    'settings' => '⚙️',
    _ => '•',
  };
}
