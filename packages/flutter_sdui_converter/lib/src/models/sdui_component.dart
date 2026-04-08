import 'sdui_prop.dart';

/// A schema entry describing a single SDUI component.
///
/// [type] matches the `"type"` field in a [SduiNode] from `flutter_sdui_kit`
/// (e.g. `"button"`, `"text"`).
///
/// [supportsAction] mirrors the single `action` slot on `SduiNode` — true when
/// the underlying Flutter widget has at least one `@SduiAction` callback.
class SduiComponent {
  final String type;
  final List<SduiProp> props;
  final bool supportsAction;

  const SduiComponent({
    required this.type,
    required this.props,
    this.supportsAction = false,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'props': props.map((p) => p.toJson()).toList(),
        'supportsAction': supportsAction,
      };

  factory SduiComponent.fromJson(Map<String, dynamic> json) => SduiComponent(
        type: json['type'] as String,
        props: (json['props'] as List<dynamic>)
            .map((p) => SduiProp.fromJson(p as Map<String, dynamic>))
            .toList(),
        supportsAction: json['supportsAction'] as bool? ?? false,
      );
}
