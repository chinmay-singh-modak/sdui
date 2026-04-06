import 'config/config_loader.dart';
import 'config/sdui_config.dart';
import 'differ/schema_differ.dart';
import 'models/models.dart';
import 'parser/component_parser.dart';
import 'scanner/file_scanner.dart';
import 'transformer/schema_transformer.dart';

const _converterVersion = '1.0.1';

class SduiConverter {
  /// Converts the Flutter project at [projectPath] into an [SduiSchema].
  ///
  /// - [config] overrides values from `flutter_sdui.yaml` (CLI args use this).
  /// - [previousSchema] enables breaking-change detection via [SchemaDiffer].
  ///
  /// On success, returns [SduiConvertResult.success] with the schema.
  /// On failure (strict mode + unknown types), returns [SduiConvertResult.failure].
  static Future<SduiConvertResult<SduiSchema, List<SduiConvertError>>> convert({
    required String projectPath,
    SduiConfig? config,
    SduiSchema? previousSchema,
  }) async {
    final loader = ConfigLoader();
    final resolvedConfig = await loader.load(projectPath, cliOverrides: config);

    final scanner = FileScanner();
    final files = await scanner.scan(projectPath, resolvedConfig.scan);

    final parser = ComponentParser();
    final rawComponents = await parser.parse(files);

    final transformer = SchemaTransformer();
    final result = transformer.transform(rawComponents, resolvedConfig, _converterVersion);

    if (result.isFailure) return result;

    // Optionally run differ if previousSchema supplied
    if (previousSchema != null) {
      final schema = result.map(onSuccess: (s) => s, onError: (_) => null)!;
      final differ = SchemaDiffer();
      final diff = differ.diff(previousSchema, schema);
      // The diff is available on the schema if callers need it; for now we
      // attach it via a wrapper so callers can inspect breaking changes.
      return SduiConvertResult.success(
        _SduiSchemaWithDiff(schema: schema, diff: diff),
      );
    }

    return result;
  }
}

/// A thin wrapper that carries the optional diff alongside the schema.
/// Callers check [diff] after a successful convert when previousSchema was supplied.
class _SduiSchemaWithDiff extends SduiSchema {
  final SchemaDiff diff;

  _SduiSchemaWithDiff({required SduiSchema schema, required this.diff})
      : super(
          schemaVersion: schema.schemaVersion,
          generatedAt: schema.generatedAt,
          generatedBy: schema.generatedBy,
          converterVersion: schema.converterVersion,
          components: schema.components,
        );
}

/// Extension to access the diff on a successful result, if one was computed.
extension SduiSchemaX on SduiSchema {
  SchemaDiff? get diff =>
      this is _SduiSchemaWithDiff ? (this as _SduiSchemaWithDiff).diff : null;
}
