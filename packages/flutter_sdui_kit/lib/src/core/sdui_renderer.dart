import 'package:flutter/widgets.dart';

import '../models/sdui_node.dart';
import '../models/sdui_screen.dart';
import '../models/sdui_theme.dart';
import 'action_handler.dart';
import 'component_registry.dart';
import 'expression_evaluator.dart';
import 'sdui_context.dart';
import 'sdui_error.dart';
import 'template_resolver.dart';

/// The rendering engine that walks an [SduiNode] tree and builds the
/// corresponding Flutter widget tree.
///
/// It ties together the [ComponentRegistry] (what to build), the
/// [ActionHandler] (what to do on interaction), and the data layer
/// (template resolution & conditional visibility).
///
/// Every error that occurs during rendering is forwarded to [onError]
/// (if provided) **and** the broken subtree is replaced with the result of
/// [errorWidgetBuilder] (or [SizedBox.shrink] by default).
///
/// ```dart
/// final renderer = SduiRenderer(
///   registry: myRegistry,
///   actionHandler: myActionHandler,
///   onError: (e) => logger.warning(e),
/// );
/// ```
class SduiRenderer {
  final ComponentRegistry registry;
  final ActionHandler actionHandler;

  /// Called for every error that occurs while rendering any node.
  final SduiErrorCallback? onError;

  /// Builds a replacement widget when a node fails to render.
  /// Defaults to returning [SizedBox.shrink].
  final SduiErrorWidgetBuilder? errorWidgetBuilder;

  SduiRenderer({
    required this.registry,
    required this.actionHandler,
    this.onError,
    this.errorWidgetBuilder,
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
    if (visibleIf != null) {
      try {
        if (!ExpressionEvaluator.evaluate(visibleIf, data)) {
          return const SizedBox.shrink();
        }
      } catch (e, stack) {
        _reportError(SduiError(
          type: SduiErrorType.expression,
          message: 'Failed to evaluate visible_if "$visibleIf": $e',
          nodeType: node.type,
          exception: e,
          stackTrace: stack,
        ));
        return const SizedBox.shrink();
      }
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

    // ── Error boundary ──────────────────────────────────────────────
    // Wrap the builder call so a single broken node (bad props, layout
    // error) does not crash the entire widget tree.
    try {
      return builder(resolvedNode, context);
    } catch (e, stack) {
      final error = SduiError(
        type: SduiErrorType.render,
        message: 'Error building "${resolvedNode.type}": $e',
        nodeType: resolvedNode.type,
        exception: e,
        stackTrace: stack,
      );
      _reportError(error);
      return _errorFallback(error);
    }
  }

  /// Forward the error to [onError] and print in debug mode.
  void _reportError(SduiError error) {
    onError?.call(error);
    assert(() {
      // ignore: avoid_print
      print('[SDUI] $error');
      return true;
    }());
  }

  /// Build the fallback widget for a broken node.
  Widget _errorFallback(SduiError error) {
    return errorWidgetBuilder?.call(error) ?? const SizedBox.shrink();
  }
}
