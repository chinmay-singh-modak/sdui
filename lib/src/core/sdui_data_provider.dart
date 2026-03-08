import 'package:flutter/widgets.dart';

/// An [InheritedWidget] that provides a data context to the SDUI tree.
///
/// Wrap [SduiWidget] (or any subtree) in an [SduiDataProvider] so that
/// template expressions (`{{user.name}}`) and conditional visibility
/// (`visible_if`) can resolve against this data.
///
/// ```dart
/// SduiDataProvider(
///   data: {
///     'user': {'name': 'John', 'is_premium': true},
///     'cart': {'count': 3},
///   },
///   child: SduiWidget(json: jsonStr),
/// )
/// ```
class SduiDataProvider extends InheritedWidget {
  /// The data map available to template expressions and conditions.
  final Map<String, dynamic> data;

  const SduiDataProvider({
    super.key,
    required this.data,
    required super.child,
  });

  /// Retrieve the nearest [SduiDataProvider] data from the widget tree.
  /// Returns an empty map if none is found.
  static Map<String, dynamic> of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<SduiDataProvider>();
    return provider?.data ?? {};
  }

  /// Like [of], but doesn't register a dependency (no rebuild on change).
  static Map<String, dynamic> read(BuildContext context) {
    final provider =
        context.getInheritedWidgetOfExactType<SduiDataProvider>();
    return provider?.data ?? {};
  }

  @override
  bool updateShouldNotify(SduiDataProvider oldWidget) {
    return data != oldWidget.data;
  }
}
