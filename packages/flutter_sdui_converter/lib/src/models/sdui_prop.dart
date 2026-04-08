class SduiProp {
  final String name;
  final String type;
  final bool required;
  final dynamic defaultValue;

  const SduiProp({
    required this.name,
    required this.type,
    required this.required,
    this.defaultValue,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'type': type,
      'required': required,
    };
    if (defaultValue != null) {
      map['default'] = defaultValue;
    }
    return map;
  }

  factory SduiProp.fromJson(Map<String, dynamic> json) => SduiProp(
        name: json['name'] as String,
        type: json['type'] as String,
        required: json['required'] as bool,
        defaultValue: json['default'],
      );

  @override
  bool operator ==(Object other) =>
      other is SduiProp &&
      other.name == name &&
      other.type == type &&
      other.required == required;

  @override
  int get hashCode => Object.hash(name, type, required);
}
