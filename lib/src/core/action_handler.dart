import '../models/sdui_action.dart';
import 'sdui_context.dart';

/// Callback signature for individual action type handlers.
typedef ActionTypeHandler = void Function(
    SduiAction action, Map<String, dynamic> payload);

/// Central dispatcher for [SduiAction]s.
///
/// Register handlers for specific action types (e.g. `navigate`, `api_call`)
/// and call [handle] when a component triggers an action. If no handler is
/// registered for the type, the optional [onUnhandled] callback is invoked.
///
/// ```dart
/// final handler = ActionHandler();
/// handler.register('navigate', (action, payload) {
///   Navigator.pushNamed(context, payload['route']);
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
  void handle(SduiAction action) {
    final handler = _handlers[action.type];
    if (handler != null) {
      handler(action, action.payload);
    } else {
      onUnhandled?.call(action, action.payload);
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
