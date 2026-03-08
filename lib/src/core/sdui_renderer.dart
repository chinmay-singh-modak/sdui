import 'package:flutter/widgets.dart';

import '../models/sdui_node.dart';
import '../models/sdui_screen.dart';
import '../models/sdui_theme.dart';
import 'action_handler.dart';
import 'component_registry.dart';
import 'expression_evaluator.dart';
import 'sdui_context.dart';
import 'template_resolver.dart';

/// The rendering engine that walks an [SduiNode] tree and builds the
/// corresponding Flutter widget tree.
///
/// It ties together the [ComponentRegistry] (what to build), the
/// [ActionHandler] (what to do on interaction), and the data layer
/// (template resolution & conditional visibility).
///
/// ```dart
/// final renderer = SduiRenderer(
///   registry: myRegistry,
///   actionHandler: myActionHandler,
/// );
///
/// // Inside a widget:
/// @override
/// Widget build(BuildContext context) {
///   return renderer.renderScreen(screen);
/// }
/// ```
class SduiRenderer {
  final ComponentRegistry registry;
  final ActionHandler actionHandler;

  SduiRenderer({
    required this.registry,
    required this.actionHandler,
  });

  /// Render a full [SduiScreen] (includes theme application).
  Widget renderScreen(SduiScreen screen, {Map<String, dynamic> data = const {}}) {
    return renderNode(screen.body, theme: screen.theme, data: data);
  }

  /// Render a single [SduiNode] (and its subtree).
  ///
  /// If the node carries a `visible_if` prop, the expression is evaluated
  /// against [data] — returning [SizedBox.shrink] when false.
  ///
  /// All string values in [SduiNode.props] are run through template
  /// resolution (`{{path}}` → value from [data]).
  Widget renderNode(
    SduiNode node, {
    SduiTheme? theme,
    Map<String, dynamic> data = const {},
  }) {
    // ── Conditional visibility ──────────────────────────────────────
    final visibleIf = node.props['visible_if'] as String?;
    if (visibleIf != null && !ExpressionEvaluator.evaluate(visibleIf, data)) {
      return const SizedBox.shrink();
    }

    // ── Template resolution ─────────────────────────────────────────
    final resolvedProps = data.isNotEmpty
        ? TemplateResolver.resolveProps(node.props, data)
        : node.props;

    final resolvedNode = resolvedProps != node.props
        ? SduiNode(
            type: node.type,
            props: resolvedProps,
            action: node.action,
            children: node.children,
          )
        : node;

    // ── Build context ───────────────────────────────────────────────
    final context = SduiContext(
      theme: theme,
      onAction: actionHandler.callback,
      data: data,
      renderChild: (child) => renderNode(child, theme: theme, data: data),
    );

    final builder = registry.resolve(resolvedNode.type);
    return builder(resolvedNode, context);
  }
}
