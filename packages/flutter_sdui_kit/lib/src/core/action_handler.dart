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
/// ### Navigation
///
/// When your app's widget tree places `SduiWidget` **above** the navigator
/// (e.g. inside `WidgetsApp(builder:)`), the `BuildContext` passed to action
/// handlers won't contain a `Navigator`. In that case, supply a
/// [navigatorKey] and use [navigatorOf] instead of `Navigator.of(context)`:
///
/// ```dart
/// final navKey = GlobalKey<NavigatorState>();
/// final handler = ActionHandler(navigatorKey: navKey);
///
/// handler.register('navigate', (context, action, payload) {
///   handler.navigatorOf(context).pushNamed(payload['route'] as String);
/// });
///
/// // Pass the same key to your app's navigator:
/// WidgetsApp(navigatorKey: navKey, ...);
/// ```
class ActionHandler {
  final Map<String, ActionTypeHandler> _handlers = {};

  /// Optional catch-all for action types that have no dedicated handler.
  ActionTypeHandler? onUnhandled;

  /// Optional navigator key used as a fallback when [BuildContext] does not
  /// contain a [Navigator] ancestor.
  ///
  /// Set this to the same [GlobalKey] you pass to your app's
  /// `WidgetsApp.navigatorKey` / `MaterialApp.navigatorKey`.
  GlobalKey<NavigatorState>? navigatorKey;

  ActionHandler({this.onUnhandled, this.navigatorKey});

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

  /// Safely obtains a [NavigatorState] for the given [context].
  ///
  /// Tries `Navigator.of(context)` first. If [context] does not have a
  /// [Navigator] ancestor (common when `SduiWidget` sits inside
  /// `WidgetsApp(builder:)`), falls back to [navigatorKey.currentState].
  ///
  /// Throws a descriptive [FlutterError] if neither approach succeeds.
  ///
  /// ```dart
  /// handler.register('navigate', (context, action, payload) {
  ///   handler.navigatorOf(context).pushNamed(payload['route'] as String);
  /// });
  /// ```
  NavigatorState navigatorOf(BuildContext context) {
    // Try the normal context-based lookup first.
    final nav = Navigator.maybeOf(context);
    if (nav != null) return nav;

    // Fall back to the global key.
    final keyNav = navigatorKey?.currentState;
    if (keyNav != null) return keyNav;

    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('ActionHandler.navigatorOf() could not find a Navigator.'),
      ErrorDescription(
        'The BuildContext used does not include a Navigator ancestor, '
        'and no navigatorKey was provided (or its currentState is null).',
      ),
      ErrorHint(
        'If your SduiWidget sits inside WidgetsApp(builder:) or '
        'MaterialApp(builder:), the context is above the Navigator. '
        'Pass the same GlobalKey<NavigatorState> to both your app and '
        'the ActionHandler:\n'
        '\n'
        '  final navKey = GlobalKey<NavigatorState>();\n'
        '  ActionHandler(navigatorKey: navKey)\n'
        '  WidgetsApp(navigatorKey: navKey, ...)\n',
      ),
    ]);
  }

  /// Returns `true` if a handler is registered for [type].
  bool has(String type) => _handlers.containsKey(type);
}
