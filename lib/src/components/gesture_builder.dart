import 'package:flutter/widgets.dart';

import '../core/sdui_context.dart';
import '../models/sdui_action.dart';
import '../models/sdui_node.dart';

/// Builds a [GestureDetector]-wrapped component.
///
/// Use this for nodes whose sole purpose is to make a subtree tappable.
///
/// Supported props:
/// - `behavior` (String) — "opaque", "translucent", "defer" (default: "opaque")
///
/// Required:
/// - `action` on the node — the action fired on tap
/// - `children` — exactly one child to wrap
Widget gestureBuilder(SduiNode node, SduiContext context) {
  final children = context.renderChildren(node.children);
  final child =
      children.length == 1 ? children.first : Column(children: children);

  final behavior = switch (node.props['behavior'] as String?) {
    'translucent' => HitTestBehavior.translucent,
    'defer' => HitTestBehavior.deferToChild,
    _ => HitTestBehavior.opaque,
  };

  return Builder(
    builder: (buildContext) => GestureDetector(
      behavior: behavior,
      onTap: node.action != null
          ? () => context.onAction?.call(buildContext, node.action!)
          : null,
      onLongPress: node.props.containsKey('long_press_action')
          ? () => context.onAction?.call(
                buildContext,
                SduiAction.fromJson(
                  node.props['long_press_action'] as Map<String, dynamic>,
                ),
              )
          : null,
      child: child,
    ),
  );
}
