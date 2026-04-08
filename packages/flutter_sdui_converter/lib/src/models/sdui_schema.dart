import 'sdui_component.dart';

class SduiSchema {
  final String schemaVersion;
  final DateTime generatedAt;
  final String generatedBy;
  final String converterVersion;
  final List<SduiComponent> components;

  const SduiSchema({
    required this.schemaVersion,
    required this.generatedAt,
    required this.generatedBy,
    required this.converterVersion,
    required this.components,
  });

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'generatedAt': generatedAt.toUtc().toIso8601String(),
        'generatedBy': generatedBy,
        'converterVersion': converterVersion,
        'components': components.map((c) => c.toJson()).toList(),
      };

  factory SduiSchema.fromJson(Map<String, dynamic> json) => SduiSchema(
        schemaVersion: json['schemaVersion'] as String,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        generatedBy: json['generatedBy'] as String,
        converterVersion: json['converterVersion'] as String,
        components: (json['components'] as List<dynamic>)
            .map((c) => SduiComponent.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}
