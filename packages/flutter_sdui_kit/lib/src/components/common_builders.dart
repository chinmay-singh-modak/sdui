import 'package:flutter/widgets.dart';

import '../core/sdui_context.dart';
import '../models/sdui_node.dart';
import '../styles/style_parser.dart';

/// Builds a scrollable container.
///
/// Supported props:
/// - `direction` (String) — "horizontal" or "vertical" (default)
///
/// **Layout safety:** the inner Column/Row uses `MainAxisSize.min` so it
/// only claims the space its children need, preventing unbounded-axis errors.
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
/// - `item_extent` (num) — fixed item size for better perf with [ListView.builder]
///
/// Uses [ListView.builder] for efficient rendering of long lists.
/// Wraps the builder in [SizedBox] with explicit `height` / `width` when the
/// list lives inside an unconstrained axis (e.g. a horizontal list inside
/// a Column). The server can send `"height"` / `"width"` props to size the
/// list explicitly.
Widget listBuilder(SduiNode node, SduiContext context) {
  final isHorizontal = node.props['direction'] == 'horizontal';
  final spacing = (node.props['spacing'] as num?)?.toDouble() ?? 0;
  final padding = node.props.containsKey('padding')
      ? StyleParser.edgeInsetsFromProps(
          node.props['padding'] as Map<String, dynamic>)
      : EdgeInsets.zero;
  final itemExtent = (node.props['item_extent'] as num?)?.toDouble();
  final width = (node.props['width'] as num?)?.toDouble();
  final height = (node.props['height'] as num?)?.toDouble();

  final children = context.renderChildren(node.children);

  // Use ListView.builder for better performance with many children.
  Widget list = ListView.builder(
    scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
    padding: padding,
    itemExtent: itemExtent,
    shrinkWrap: true,
    // shrinkWrap + NeverScrollableScrollPhysics makes the list play
    // nicely when nested inside another scrollable. If it IS the
    // primary scrollable the user can override via a wrapper scroll.
    physics: const NeverScrollableScrollPhysics(),
    itemCount: children.length + (spacing > 0 ? children.length - 1 : 0),
    itemBuilder: (_, index) {
      if (spacing > 0) {
        // Even indices → real children, odd indices → spacers.
        if (index.isOdd) {
          return SizedBox(
            width: isHorizontal ? spacing : 0,
            height: isHorizontal ? 0 : spacing,
          );
        }
        return children[index ~/ 2];
      }
      return children[index];
    },
  );

  // Constrain the cross-axis if the server provides explicit dimensions.
  // This prevents "unbounded height" when a horizontal list sits inside a
  // Column (or "unbounded width" for a vertical list inside a Row).
  if (width != null || height != null) {
    list = SizedBox(width: width, height: height, child: list);
  }

  return list;
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

  final cardWidget = Container(
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
    return Builder(
      builder: (buildContext) => GestureDetector(
        onTap: () => context.onAction?.call(buildContext, node.action!),
        child: cardWidget,
      ),
    );
  }

  return cardWidget;
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

// ─── Layout-aware wrappers ──────────────────────────────────────────────

/// Builds a [SafeArea] wrapper.
///
/// Supported props:
/// - `top` (bool) — default `true`
/// - `bottom` (bool) — default `true`
/// - `left` (bool) — default `true`
/// - `right` (bool) — default `true`
Widget safeAreaBuilder(SduiNode node, SduiContext context) {
  final children = context.renderChildren(node.children);
  final child = children.length == 1
      ? children.first
      : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );

  return SafeArea(
    top: node.props['top'] as bool? ?? true,
    bottom: node.props['bottom'] as bool? ?? true,
    left: node.props['left'] as bool? ?? true,
    right: node.props['right'] as bool? ?? true,
    child: child,
  );
}

/// Builds an [Expanded] or [Flexible] wrapper.
///
/// This is the JSON-side way to tell the renderer "this child should fill
/// remaining space in its parent Row/Column."
///
/// Supported props:
/// - `flex` (int) — flex factor, default 1
/// - `fit` (String) — "tight" (Expanded) or "loose" (Flexible), default "tight"
///
/// **Note:** Also supported inline via `"flex"` prop on any child node —
/// see [layout_builders.dart]. This builder is for when you want an explicit
/// `expanded` node in the JSON.
Widget expandedBuilder(SduiNode node, SduiContext context) {
  final flex = (node.props['flex'] as num?)?.toInt() ?? 1;
  final isLoose = node.props['fit'] == 'loose';

  final children = context.renderChildren(node.children);
  final child = children.length == 1
      ? children.first
      : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );

  return isLoose
      ? Flexible(flex: flex, child: child)
      : Expanded(flex: flex, child: child);
}

/// Builds a [Center] wrapper.
///
/// Simple but frequently needed to center content without specifying
/// alignment on the parent.
Widget centerBuilder(SduiNode node, SduiContext context) {
  final children = context.renderChildren(node.children);
  final child = children.length == 1
      ? children.first
      : Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );

  return Center(child: child);
}

/// Builds an [AspectRatio] wrapper.
///
/// Supported props:
/// - `ratio` (num) — the width:height ratio (e.g. 1.78 for 16:9)
Widget aspectRatioBuilder(SduiNode node, SduiContext context) {
  final ratio = (node.props['ratio'] as num?)?.toDouble() ?? 1.0;
  final children = context.renderChildren(node.children);
  final child = children.isNotEmpty ? children.first : const SizedBox.shrink();

  return AspectRatio(
    aspectRatio: ratio,
    child: child,
  );
}

/// Builds a [ConstrainedBox] wrapper for explicit min/max sizing.
///
/// Supported props:
/// - `min_width` (num)
/// - `max_width` (num)
/// - `min_height` (num)
/// - `max_height` (num)
Widget constrainedBoxBuilder(SduiNode node, SduiContext context) {
  final minWidth = (node.props['min_width'] as num?)?.toDouble() ?? 0;
  final maxWidth =
      (node.props['max_width'] as num?)?.toDouble() ?? double.infinity;
  final minHeight = (node.props['min_height'] as num?)?.toDouble() ?? 0;
  final maxHeight =
      (node.props['max_height'] as num?)?.toDouble() ?? double.infinity;

  final children = context.renderChildren(node.children);
  final child = children.isNotEmpty ? children.first : const SizedBox.shrink();

  return ConstrainedBox(
    constraints: BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    ),
    child: child,
  );
}
