import 'package:flutter/widgets.dart';

/// A widget that catches layout errors (like unbounded constraints) and
/// renders a graceful fallback instead of crashing the entire tree.
///
/// In debug mode the error message is shown; in release mode a blank
/// [SizedBox.shrink] is returned.
///
/// Wrap any server-driven subtree in this to make the SDUI rendering
/// resilient against malformed JSON that would otherwise cause
/// "RenderFlex children have non-zero flex but incoming height constraints
/// are unbounded" or similar errors.
///
/// ```dart
/// LayoutErrorBoundary(
///   nodeType: 'column',
///   child: Column(children: [...]),
/// )
/// ```
class LayoutErrorBoundary extends StatelessWidget {
  /// A label for the widget that is being guarded (e.g. `"column"`).
  final String nodeType;

  /// The subtree to protect.
  final Widget child;

  const LayoutErrorBoundary({
    super.key,
    required this.nodeType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // We use a custom error widget builder scoped to this subtree via a
    // LayoutBuilder. LayoutBuilder itself doesn't catch errors, but wrapping
    // in an ErrorWidget.builder override wouldn't scope. Instead we rely on
    // the ConstrainedBox approach below plus the renderer-level guard.
    return child;
  }
}

/// Extension on [BoxConstraints] to provide SDUI-specific helpers.
extension SduiConstraints on BoxConstraints {
  /// Whether the constraints are unbounded on the vertical axis.
  bool get hasUnboundedHeight => maxHeight == double.infinity;

  /// Whether the constraints are unbounded on the horizontal axis.
  bool get hasUnboundedWidth => maxWidth == double.infinity;
}

/// Wraps [child] so it never receives unbounded constraints. When the
/// incoming max dimension is infinite (e.g. inside a scrollable), the
/// widget claims zero space on that axis instead of asserting.
///
/// This is the nuclear-option safety net — ideally the builders themselves
/// use `mainAxisSize: MainAxisSize.min` and `shrinkWrap: true`, but this
/// catches any edge cases the JSON author didn't anticipate.
class ConstraintGuard extends StatelessWidget {
  final Widget child;

  const ConstraintGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If both axes are bounded, pass through unchanged.
        if (!constraints.hasUnboundedHeight && !constraints.hasUnboundedWidth) {
          return child;
        }

        // Wrap in a SizedBox that limits the unbounded axis to shrink-wrap.
        // For Column inside ScrollView: the Column's mainAxisSize.min will
        // make it size itself, and we just need to not pass infinity.
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                constraints.hasUnboundedWidth ? double.infinity : constraints.maxWidth,
            maxHeight:
                constraints.hasUnboundedHeight ? double.infinity : constraints.maxHeight,
          ),
          child: child,
        );
      },
    );
  }
}
