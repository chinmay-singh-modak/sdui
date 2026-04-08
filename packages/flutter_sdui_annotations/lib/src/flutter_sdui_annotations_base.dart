import 'package:meta/meta.dart';

/// Marks a Flutter widget class as an SDUI component.
///
/// The [name] is the component identifier used in the generated JSON schema.
///
/// ```dart
/// @SduiComponent(name: 'PrimaryButton')
/// class PrimaryButton extends StatelessWidget { ... }
/// ```
@immutable
class SduiComponent {
  final String name;
  const SduiComponent({required this.name});
}

/// Marks a constructor field as an SDUI prop.
///
/// The optional [defaultValue] overrides the value inferred from the
/// constructor default. If omitted, the converter inspects the constructor
/// parameter default directly.
///
/// ```dart
/// @SduiProp(defaultValue: 'blue')
/// final String color;
/// ```
@immutable
class SduiProp {
  final dynamic defaultValue;
  const SduiProp({this.defaultValue});
}

/// Marks a callback field as an SDUI action.
///
/// Action fields are emitted separately from props in the schema and do not
/// carry a type or default value.
///
/// ```dart
/// @SduiAction()
/// final VoidCallback? onTap;
/// ```
@immutable
class SduiAction {
  const SduiAction();
}
