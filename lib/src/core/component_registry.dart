import 'package:flutter/widgets.dart';

import '../models/sdui_node.dart';
import 'sdui_context.dart';

/// A registry that maps component `type` strings to their [ComponentBuilder]s.
///
/// The registry is the single source of truth that the renderer consults to
/// decide how to turn an [SduiNode] into a Flutter widget.
///
/// Usage:
/// ```dart
/// final registry = ComponentRegistry();
/// registry.register('text', textBuilder);
/// registry.register('column', columnBuilder);
/// ```
class ComponentRegistry {
  final Map<String, ComponentBuilder> _builders = {};

  /// Fallback builder used when a component type is not registered.
  ComponentBuilder _fallback = _defaultFallback;

  /// Register a [builder] for the given component [type].
  ///
  /// Overwrites any previously registered builder for the same type.
  void register(String type, ComponentBuilder builder) {
    _builders[type] = builder;
  }

  /// Register multiple builders at once.
  void registerAll(Map<String, ComponentBuilder> builders) {
    _builders.addAll(builders);
  }

  /// Remove the builder for [type].
  void unregister(String type) {
    _builders.remove(type);
  }

  /// Override the default fallback builder that is used for unknown types.
  void setFallback(ComponentBuilder builder) {
    _fallback = builder;
  }

  /// Returns `true` if a builder is registered for [type].
  bool has(String type) => _builders.containsKey(type);

  /// Resolve the builder for [type], falling back to [_fallback].
  ComponentBuilder resolve(String type) => _builders[type] ?? _fallback;

  /// Returns all registered type identifiers.
  Iterable<String> get registeredTypes => _builders.keys;

  // ── Default fallback ─────────────────────────────────────────────────

  static Widget _defaultFallback(SduiNode node, SduiContext context) {
    assert(() {
      // ignore: avoid_print
      print('[SDUI] No builder registered for type "${node.type}"');
      return true;
    }());
    return const SizedBox.shrink();
  }
}
