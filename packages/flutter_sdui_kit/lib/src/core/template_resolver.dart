import 'expression_evaluator.dart';

/// Resolves `{{path.to.value}}` template placeholders in strings
/// against a data map.
///
/// ```dart
/// final result = TemplateResolver.resolve(
///   'Hello, {{user.name}}! You have {{cart.count}} items.',
///   {'user': {'name': 'John'}, 'cart': {'count': 3}},
/// );
/// // → 'Hello, John! You have 3 items.'
/// ```
class TemplateResolver {
  TemplateResolver._();

  static final _pattern = RegExp(r'\{\{(.+?)\}\}');

  /// Replace all `{{…}}` placeholders in [template] with values from [data].
  ///
  /// Unresolved placeholders are left as-is (or replaced with empty string
  /// if [removeUnresolved] is true).
  static String resolve(
    String template,
    Map<String, dynamic> data, {
    bool removeUnresolved = false,
  }) {
    return template.replaceAllMapped(_pattern, (match) {
      final path = match.group(1)!.trim();
      final value = ExpressionEvaluator.resolvePath(path, data);
      if (value != null) return value.toString();
      return removeUnresolved ? '' : match.group(0)!;
    });
  }

  /// Recursively resolve templates in all string values within a props map.
  static Map<String, dynamic> resolveProps(
    Map<String, dynamic> props,
    Map<String, dynamic> data,
  ) {
    return props.map((key, value) {
      if (value is String) {
        return MapEntry(key, resolve(value, data));
      }
      if (value is Map<String, dynamic>) {
        return MapEntry(key, resolveProps(value, data));
      }
      if (value is List) {
        return MapEntry(
          key,
          value.map((e) {
            if (e is String) return resolve(e, data);
            if (e is Map<String, dynamic>) return resolveProps(e, data);
            return e;
          }).toList(),
        );
      }
      return MapEntry(key, value);
    });
  }
}
