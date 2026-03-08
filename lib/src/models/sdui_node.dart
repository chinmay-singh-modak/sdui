import 'sdui_action.dart';

/// A single node in the server-driven component tree.
///
/// Every JSON node with a `"type"` key becomes an [SduiNode]. Leaf nodes simply
/// have an empty [children] list.
class SduiNode {
  /// The component type identifier (e.g. "text", "column", "button").
  final String type;

  /// Arbitrary properties for the component (sizes, colors, content, etc.).
  final Map<String, dynamic> props;

  /// Optional action attached to this node (tap, long-press, etc.).
  final SduiAction? action;

  /// Ordered child nodes.
  final List<SduiNode> children;

  const SduiNode({
    required this.type,
    this.props = const {},
    this.action,
    this.children = const [],
  });

  /// Recursively parses a JSON map into an [SduiNode] tree.
  factory SduiNode.fromJson(Map<String, dynamic> json) {
    return SduiNode(
      type: json['type'] as String,
      props: (json['props'] as Map<String, dynamic>?) ?? {},
      action: json.containsKey('action')
          ? SduiAction.fromJson(json['action'] as Map<String, dynamic>)
          : null,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => SduiNode.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        if (props.isNotEmpty) 'props': props,
        if (action != null) 'action': action!.toJson(),
        if (children.isNotEmpty)
          'children': children.map((c) => c.toJson()).toList(),
      };

  @override
  String toString() =>
      'SduiNode(type: $type, props: $props, children: ${children.length})';
}
