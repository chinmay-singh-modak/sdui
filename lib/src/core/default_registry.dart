import 'component_registry.dart';
import '../components/text_builder.dart';
import '../components/layout_builders.dart';
import '../components/container_builders.dart';
import '../components/image_builder.dart';
import '../components/button_builder.dart';
import '../components/common_builders.dart';
import '../components/form_builders.dart';
import '../components/gesture_builder.dart';

/// Creates a [ComponentRegistry] pre-loaded with all built-in component
/// builders.
///
/// You can extend the returned registry with custom builders:
/// ```dart
/// final registry = createDefaultRegistry();
/// registry.register('my_widget', myWidgetBuilder);
/// ```
ComponentRegistry createDefaultRegistry() {
  final registry = ComponentRegistry();
  registry.registerAll({
    // Layout
    'column': columnBuilder,
    'row': rowBuilder,
    'padding': paddingBuilder,
    'sizedbox': sizedBoxBuilder,
    'container': containerBuilder,
    'scroll': scrollBuilder,

    // Content
    'text': textBuilder,
    'image': imageBuilder,
    'button': buttonBuilder,
    'icon': iconBuilder,

    // Composite
    'card': cardBuilder,
    'list': listBuilder,
    'divider': dividerBuilder,

    // Form
    'text_input': textInputBuilder,
    'checkbox': checkboxBuilder,
    'switch': switchBuilder,
    'dropdown': dropdownBuilder,

    // Interaction
    'gesture': gestureBuilder,
  });
  return registry;
}
