import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'core/action_handler.dart';
import 'core/component_registry.dart';
import 'core/default_registry.dart';
import 'core/sdui_data_provider.dart';
import 'core/sdui_error.dart';
import 'core/sdui_renderer.dart';
import 'models/sdui_screen.dart';

/// A drop-in Flutter widget that renders a full server-driven screen from
/// a JSON string.
///
/// ## Minimal usage
/// ```dart
/// SduiWidget(json: serverResponseString)
/// ```
///
/// ## With error handling
/// ```dart
/// SduiWidget(
///   json: serverResponseString,
///   actionHandler: myActions,
///   data: {'user': {'name': 'John'}},
///   onError: (error) => analytics.logError(error.message),
///   errorWidgetBuilder: (error) => Text('Oops: ${error.message}'),
///   fallback: CircularProgressIndicator(),
/// )
/// ```
class SduiWidget extends StatelessWidget {
  /// Raw JSON string representing the server response.
  /// This is the only required input — everything else is optional.
  final String? json;

  /// The component registry to use. If `null`, the default built-in registry
  /// is created automatically via [createDefaultRegistry].
  final ComponentRegistry? registry;

  /// The action handler that resolves user interactions.
  final ActionHandler? actionHandler;

  /// Data context for template expressions (`{{user.name}}`) and conditional
  /// visibility (`visible_if`). Also provided to the subtree via
  /// [SduiDataProvider].
  final Map<String, dynamic> data;

  /// Widget shown when [json] is `null`, empty, or fails to parse.
  ///
  /// Unlike [errorWidgetBuilder], this is a **static** widget — it does not
  /// receive error details. Use it for a generic "loading" or "empty state"
  /// placeholder.
  final Widget fallback;

  /// Called for **every** error that occurs during parsing or rendering.
  ///
  /// Use this to log errors, send them to Crashlytics / Sentry, or display
  /// a toast. The tree will still render — the broken node is replaced with
  /// the result of [errorWidgetBuilder] (or [SizedBox.shrink]).
  final SduiErrorCallback? onError;

  /// Builds a replacement widget for any individual node that fails to
  /// render. If `null`, broken nodes silently become [SizedBox.shrink].
  ///
  /// ```dart
  /// errorWidgetBuilder: (error) => Container(
  ///   color: Color(0x33FF0000),
  ///   padding: EdgeInsets.all(8),
  ///   child: Text('Error: ${error.message}'),
  /// )
  /// ```
  final SduiErrorWidgetBuilder? errorWidgetBuilder;

  const SduiWidget({
    super.key,
    required this.json,
    this.registry,
    this.actionHandler,
    this.data = const {},
    this.fallback = const SizedBox.shrink(),
    this.onError,
    this.errorWidgetBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedScreen = _parseJson();
    if (resolvedScreen == null) return fallback;

    // Merge data from an ancestor SduiDataProvider with locally provided data.
    final ancestorData = SduiDataProvider.read(context);
    final mergedData = {...ancestorData, ...data};

    final renderer = SduiRenderer(
      registry: registry ?? createDefaultRegistry(),
      actionHandler: actionHandler ?? ActionHandler(),
      onError: onError,
      errorWidgetBuilder: errorWidgetBuilder,
    );

    final rendered = renderer.renderScreen(resolvedScreen, data: mergedData);

    // Provide the merged data to any nested SduiWidgets.
    return SduiDataProvider(
      data: mergedData,
      child: rendered,
    );
  }

  SduiScreen? _parseJson() {
    if (json == null || json!.isEmpty) return null;
    try {
      final data = jsonDecode(json!) as Map<String, dynamic>;
      return SduiScreen.fromJson(data);
    } catch (e, stack) {
      final error = SduiError(
        type: SduiErrorType.parse,
        message: 'Failed to parse JSON: $e',
        exception: e,
        stackTrace: stack,
      );
      onError?.call(error);
      assert(() {
        // ignore: avoid_print
        print('[SDUI] $error');
        return true;
      }());
      return null;
    }
  }
}
