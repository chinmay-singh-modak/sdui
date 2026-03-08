import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'core/action_handler.dart';
import 'core/component_registry.dart';
import 'core/default_registry.dart';
import 'core/sdui_data_provider.dart';
import 'core/sdui_renderer.dart';
import 'models/sdui_screen.dart';

/// A drop-in Flutter widget that renders a full server-driven screen.
///
/// Provide either a raw [json] string **or** a pre-parsed [screen] model.
///
/// ```dart
/// SduiWidget(
///   json: serverResponseString,
///   actionHandler: myActionHandler,
///   data: {'user': {'name': 'John'}},
/// )
/// ```
class SduiWidget extends StatelessWidget {
  /// Raw JSON string representing the [SduiScreen]. Mutually exclusive with
  /// [screen].
  final String? json;

  /// Pre-parsed screen model. Mutually exclusive with [json].
  final SduiScreen? screen;

  /// The component registry to use. If `null`, the default built-in registry
  /// is created automatically.
  final ComponentRegistry? registry;

  /// The action handler that resolves user interactions.
  final ActionHandler? actionHandler;

  /// Data context for template expressions (`{{user.name}}`) and conditional
  /// visibility (`visible_if`). Also provided to the subtree via
  /// [SduiDataProvider].
  final Map<String, dynamic> data;

  /// Widget shown when the JSON is `null`, empty, or fails to parse.
  final Widget errorWidget;

  const SduiWidget({
    super.key,
    this.json,
    this.screen,
    this.registry,
    this.actionHandler,
    this.data = const {},
    this.errorWidget = const SizedBox.shrink(),
  }) : assert(json != null || screen != null,
            'Provide either json or screen');

  @override
  Widget build(BuildContext context) {
    final resolvedScreen = screen ?? _parseJson();
    if (resolvedScreen == null) return errorWidget;

    // Merge data from an ancestor SduiDataProvider with locally provided data.
    final ancestorData = SduiDataProvider.read(context);
    final mergedData = {...ancestorData, ...data};

    final renderer = SduiRenderer(
      registry: registry ?? createDefaultRegistry(),
      actionHandler: actionHandler ?? ActionHandler(),
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
    } catch (e) {
      assert(() {
        // ignore: avoid_print
        print('[SDUI] Failed to parse JSON: $e');
        return true;
      }());
      return null;
    }
  }
}
