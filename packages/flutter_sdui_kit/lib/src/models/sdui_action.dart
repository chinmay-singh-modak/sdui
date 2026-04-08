/// Represents an action triggered by user interaction on a server-driven component.
///
/// Actions are declarative — the server defines what should happen (navigate,
/// call an API, open a sheet, etc.) and the client resolves it at runtime via
/// the [ActionHandler] registry.
class SduiAction {
  /// The action type identifier (e.g. "navigate", "api_call", "open_sheet").
  final String type;

  /// Arbitrary payload associated with the action.
  final Map<String, dynamic> payload;

  const SduiAction({
    required this.type,
    this.payload = const {},
  });

  factory SduiAction.fromJson(Map<String, dynamic> json) {
    return SduiAction(
      type: json['type'] as String,
      payload: (json['payload'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'payload': payload,
      };

  @override
  String toString() => 'SduiAction(type: $type, payload: $payload)';
}
