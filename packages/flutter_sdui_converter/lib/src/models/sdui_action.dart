class SduiAction {
  final String name;

  const SduiAction({required this.name});

  Map<String, dynamic> toJson() => {'name': name};

  factory SduiAction.fromJson(Map<String, dynamic> json) =>
      SduiAction(name: json['name'] as String);

  @override
  bool operator ==(Object other) =>
      other is SduiAction && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
