import 'package:flutter/widgets.dart';

import '../models/sdui_action.dart';
import '../models/sdui_node.dart';
import '../models/sdui_theme.dart';

/// Context passed down to every component builder during rendering.
///
/// Gives builders access to the screen's theme, action handler, data context,
/// and a way to recursively render child nodes.
class SduiContext {
  /// Theme overrides for the current screen.
  final SduiTheme? theme;

  /// Callback that resolves [SduiAction]s at runtime.
  ///
  /// Component builders should call this with the Flutter [BuildContext] from
  /// their `build()` method so that action handlers can use it for navigation,
  /// dialogs, snackbars, etc.
  final ActionCallback? onAction;

  /// Reference to the renderer so builders can render children.
  final Widget Function(SduiNode node) renderChild;

  /// Data map for template resolution and conditional logic.
  final Map<String, dynamic> data;

  const SduiContext({
    this.theme,
    this.onAction,
    required this.renderChild,
    this.data = const {},
  });

  /// Convenience: render a list of child nodes into widgets.
  List<Widget> renderChildren(List<SduiNode> nodes) =>
      nodes.map(renderChild).toList();
}

/// Signature for the function that builds a widget from an [SduiNode].
typedef ComponentBuilder = Widget Function(SduiNode node, SduiContext context);

/// Signature for the action callback invoked when a user interacts with
/// a component that carries an [SduiAction].
///
/// The [BuildContext] is the context of the widget that triggered the action,
/// giving handlers access to [Navigator.of], [Overlay.of], etc.
typedef ActionCallback = void Function(BuildContext context, SduiAction action);
