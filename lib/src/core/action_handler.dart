import 'package:flutter/widgets.dart';

import '../models/sdui_action.dart';
import 'sdui_context.dart';

/// Callback signature for individual action type handlers.
///
/// The [BuildContext] is the context of the widget that triggered the action
/// (e.g. the button that was tapped). Use it for [Navigator.of],
/// [Overlay.of], showing dialogs, etc.
typedef ActionTypeHandler = void Function(
    BuildContext context, SduiAction action, Map<String, dynamic> payload);

/// Central dispatcher for [SduiAction]s.
///
/// Register handlers for specific action types (e.g. `navigate`, `api_call`)
/// and call [handle] when a component triggers an action. If no handler is
/// registered for the type, the optional [onUnhandled] callback is invoked.
///
/// ```dart
/// final handler = ActionHandler();
/// handler.register('navigate', (context, action, payload) {
///   Navigator.of(context).pushNamed(payload['route'] as String);
/// });
/// ```
class ActionHandler {
  final Map<String, ActionTypeHandler> _handlers = {};

  /// Optional catch-all for action types that have no dedicated handler.
  ActionTypeHandler? onUnhandled;

  ActionHandler({this.onUnhandled});

  /// Register a handler for the given action [type].
  void register(String type, ActionTypeHandler handler) {
    _handlers[type] = handler;
  }

  /// Register multiple handlers at once.
  void registerAll(Map<String, ActionTypeHandler> handlers) {
    _handlers.addAll(handlers);
  }

  /// Remove the handler for [type].
  void unregister(String type) {
    _handlers.remove(type);
  }

  /// Dispatch an [SduiAction] to the matching registered handler.
  ///
  /// The [context] is the Flutter [BuildContext] of the widget that triggered
  /// this action — it is forwarded to the handler so it can navigate, show
  /// dialogs, etc.
  void handle(BuildContext context, SduiAction action) {
    final handler = _handlers[action.type];
    if (handler != null) {
      handler(context, action, action.payload);
    } else {
      onUnhandled?.call(context, action, action.payload);
      assert(() {
        // ignore: avoid_print
        print('[SDUI] Unhandled action type: "${action.type}"');
        return true;
      }());
    }
  }

  /// Returns an [ActionCallback] suitable for passing into [SduiContext].
  ActionCallback get callback => handle;

  /// Returns `true` if a handler is registered for [type].
  bool has(String type) => _handlers.containsKey(type);
}
