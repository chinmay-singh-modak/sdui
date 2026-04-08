import 'package:flutter/widgets.dart';

/// Describes *what* went wrong during SDUI rendering.
enum SduiErrorType {
  /// The incoming JSON could not be decoded or mapped to an [SduiScreen].
  parse,

  /// A component builder threw an exception while building a node.
  render,

  /// No builder was found for the node's `type` (and no fallback was set on
  /// the registry).
  unknownComponent,

  /// An expression in `visible_if` failed to evaluate.
  expression,
}

/// A structured error produced during SDUI rendering.
///
/// Includes the [type] of error, a human-readable [message], the optional
/// raw [exception] / [stackTrace], and the [nodeType] that was being
/// processed (when available).
class SduiError {
  /// Classification of the error.
  final SduiErrorType type;

  /// Human-readable description.
  final String message;

  /// The SDUI node type that was being processed (e.g. `"column"`).
  final String? nodeType;

  /// The underlying Dart exception, if any.
  final Object? exception;

  /// Stack trace at the point the error occurred.
  final StackTrace? stackTrace;

  const SduiError({
    required this.type,
    required this.message,
    this.nodeType,
    this.exception,
    this.stackTrace,
  });

  @override
  String toString() =>
      'SduiError(${type.name}${nodeType != null ? ', node: $nodeType' : ''}): $message';
}

/// Callback signature for receiving SDUI errors.
///
/// ```dart
/// SduiWidget(
///   json: rawJson,
///   onError: (error) {
///     logger.warning(error.toString());
///     // Optionally send to Crashlytics / Sentry
///   },
/// )
/// ```
typedef SduiErrorCallback = void Function(SduiError error);

/// Optional widget builder that receives the [SduiError] and returns a widget
/// to display in place of the broken subtree.
///
/// ```dart
/// SduiWidget(
///   json: rawJson,
///   errorWidgetBuilder: (error) => Text('Failed: ${error.message}'),
/// )
/// ```
typedef SduiErrorWidgetBuilder = Widget Function(SduiError error);
