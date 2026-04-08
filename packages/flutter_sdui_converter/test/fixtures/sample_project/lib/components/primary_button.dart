import 'package:flutter_sdui_annotations/flutter_sdui_annotations.dart';

@SduiComponent(name: 'PrimaryButton')
class PrimaryButton {
  @SduiProp()
  final String label;

  @SduiProp(defaultValue: 'blue')
  final String color;

  @SduiAction()
  final void Function()? onTap;

  const PrimaryButton({
    required this.label,
    this.color = 'blue',
    this.onTap,
  });
}
