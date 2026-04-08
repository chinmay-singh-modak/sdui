import '../config/sdui_config.dart';
import '../models/models.dart';
import '../parser/raw_component.dart';

const _generatedBy = 'flutter_sdui_converter';

/// Maps Dart type names to SDUI type strings.
const _typeMap = <String, String>{
  'String': 'string',
  'int': 'integer',
  'double': 'number',
  'num': 'number',
  'bool': 'boolean',
  'Color': 'color',
};

/// Dart callback types that should be treated as actions (not props).
const _actionTypes = {'VoidCallback', 'Function'};

/// Returns `true` for types that are action-like (callbacks).
bool _isActionType(String dartType) {
  final base = dartType.replaceAll(RegExp(r'\?$'), '');
  if (_actionTypes.contains(base)) return true;
  if (base.startsWith('Function(')) return true;
  return false;
}

/// Returns the SDUI type for [dartType], or `null` if unknown.
String? _mapType(String dartType) {
  final base = dartType.replaceAll(RegExp(r'\?$'), '');
  if (_typeMap.containsKey(base)) return _typeMap[base];
  if (base.startsWith('List<')) return 'array';
  if (base.startsWith('Map<')) return 'object';
  return null;
}

class SchemaTransformer {
  /// Converts raw AST data into a [SduiSchema].
  ///
  /// Returns [SduiConvertResult.failure] if [config.flags.strictMode] is true
  /// and any unknown Dart types are encountered.
  SduiConvertResult<SduiSchema, List<SduiConvertError>> transform(
    List<RawComponent> rawComponents,
    SduiConfig config,
    String converterVersion,
  ) {
    final errors = <SduiConvertError>[];
    final components = <SduiComponent>[];

    for (final raw in rawComponents) {
      final props = <SduiProp>[];
      // Any @SduiAction param → the component supports the action slot.
      var supportsAction = raw.actions.isNotEmpty;

      for (final rawProp in raw.props) {
        // Callback types are re-classified as the action slot, not props.
        if (_isActionType(rawProp.dartType)) {
          supportsAction = true;
          continue;
        }

        final sduiType = _mapType(rawProp.dartType);

        if (sduiType == null) {
          if (config.flags.strictMode) {
            errors.add(SduiConvertError(
              message:
                  'Unknown Dart type "${rawProp.dartType}" for prop '
                  '"${rawProp.fieldName}" in component "${raw.sduiName}"',
              file: raw.sourceFile,
            ));
            continue;
          } else {
            // Fall back to 'any' with no error in non-strict mode
          }
        }

        final required = !rawProp.isNullable && !rawProp.hasDefaultValue;

        props.add(SduiProp(
          name: rawProp.fieldName,
          type: sduiType ?? 'any',
          required: required,
          defaultValue: rawProp.hasDefaultValue ? rawProp.defaultValue : null,
        ));
      }

      components.add(SduiComponent(
        type: raw.sduiName,
        props: props,
        supportsAction: supportsAction,
      ));
    }

    if (errors.isNotEmpty) {
      return SduiConvertResult.failure(errors);
    }

    final schema = SduiSchema(
      schemaVersion: config.version,
      generatedAt: DateTime.now().toUtc(),
      generatedBy: _generatedBy,
      converterVersion: converterVersion,
      components: components,
    );

    return SduiConvertResult.success(schema);
  }
}
