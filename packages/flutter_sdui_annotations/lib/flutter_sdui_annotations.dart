/// Lightweight annotations for marking Flutter widgets as SDUI components.
///
/// Apply these annotations to your widget classes and their fields so that
/// `flutter_sdui_converter` can generate a JSON schema describing your UI
/// component library.
///
/// Three annotations are provided:
///
/// - [SduiComponent] — marks a widget class as an SDUI component.
/// - [SduiProp] — marks a constructor field as a configurable prop.
/// - [SduiAction] — marks a callback field as an action slot.
///
/// ```dart
/// @SduiComponent(name: 'PrimaryButton')
/// class PrimaryButton extends StatelessWidget {
///   @SduiProp()
///   final String label;
///
///   @SduiAction()
///   final VoidCallback? onTap;
///
///   const PrimaryButton({required this.label, this.onTap});
/// }
/// ```
library;

export 'src/flutter_sdui_annotations_base.dart';
