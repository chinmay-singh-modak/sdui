import 'package:flutter_sdui_annotations/flutter_sdui_annotations.dart';

/// Example: annotating a Flutter widget for SDUI schema generation.
///
/// Run `dart run flutter_sdui_converter` on a project containing this widget
/// to produce a JSON schema entry for `PrimaryButton`.

@SduiComponent(name: 'PrimaryButton')
class PrimaryButton {
  @SduiProp()
  final String label;

  @SduiProp(defaultValue: 'blue')
  final String color;

  @SduiProp(defaultValue: 14.0)
  final double fontSize;

  @SduiAction()
  final void Function()? onTap;

  const PrimaryButton({
    required this.label,
    this.color = 'blue',
    this.fontSize = 14.0,
    this.onTap,
  });
}

void main() {
  // Annotations are compile-time metadata — they have no runtime behaviour.
  // The flutter_sdui_converter reads them via the Dart analyzer AST.
  const component = SduiComponent(name: 'PrimaryButton');
  print('Component name: ${component.name}');

  const prop = SduiProp(defaultValue: 'blue');
  print('Prop default: ${prop.defaultValue}');

  const action = SduiAction();
  print('Action created: $action');
}
