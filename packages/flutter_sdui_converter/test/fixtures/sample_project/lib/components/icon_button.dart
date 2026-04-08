import 'package:flutter_sdui_annotations/flutter_sdui_annotations.dart';

@SduiComponent(name: 'IconButton')
class IconButton {
  @SduiProp()
  final String icon;

  @SduiProp()
  final int size;

  @SduiProp()
  final bool enabled;

  @SduiAction()
  final void Function()? onPress;

  const IconButton({
    required this.icon,
    required this.size,
    this.enabled = true,
    this.onPress,
  });
}
