import 'dart:io';

import 'package:flutter_sdui_converter/flutter_sdui_converter.dart';

// Run from your Flutter project root:
//   dart run flutter_sdui_converter --input . --output sdui_schema.json
//
// Or call programmatically (e.g. from the Vyne CLI):

Future<void> main() async {
  final projectPath = Directory.current.path;

  // ── Basic usage ──────────────────────────────────────────────────────────
  // Auto-discovers flutter_sdui.yaml; scans lib/ by default.
  final result = await SduiConverter.convert(projectPath: projectPath);

  result.fold(
    onSuccess: (schema) {
      print('Converted ${schema.components.length} component(s).');
      for (final c in schema.components) {
        final props = c.props.map((p) => p.name).join(', ');
        print('  ${c.type} — props: $props');
      }

      // Write to disk (optional — callers can also consume schema directly).
      final json = JsonEmitter().emit(schema);
      File('sdui_schema.json').writeAsStringSync(json);
      print('Schema written to sdui_schema.json');
    },
    onError: (errors) {
      for (final e in errors) {
        stderr.writeln(e);
      }
      exitCode = 1;
    },
  );

  // ── With config override ─────────────────────────────────────────────────
  // CLI flags or programmatic callers (e.g. Vyne CLI) can override any
  // value from flutter_sdui.yaml.
  final result2 = await SduiConverter.convert(
    projectPath: projectPath,
    config: SduiConfig(
      outputPath: 'build/sdui_schema.json',
      scan: ScanConfig(
        include: ['lib/components', 'lib/widgets'],
        exclude: ['lib/generated'],
      ),
      flags: FeatureFlags(strictMode: true),
    ),
  );

  result2.fold(
    onSuccess: (schema) => print('Schema version: ${schema.schemaVersion}'),
    onError: (errors) => errors.forEach(stderr.writeln),
  );

  // ── Breaking-change detection ────────────────────────────────────────────
  // Supply a previous schema to detect breaking changes before publishing.
  // Vyne CLI fetches the last published schema from the backend automatically;
  // standalone users can load a local copy:
  //
  // final previousJson = File('sdui_schema.v1.json').readAsStringSync();
  // final previous = SduiSchema.fromJson(jsonDecode(previousJson));
  //
  // final result3 = await SduiConverter.convert(
  //   projectPath: projectPath,
  //   previousSchema: previous,
  // );
  //
  // result3.fold(
  //   onSuccess: (schema) {
  //     final diff = schema.diff;
  //     if (diff != null && diff.hasBreakingChanges) {
  //       print('Breaking changes detected — bump version in flutter_sdui.yaml');
  //       for (final change in diff.breaking) {
  //         print('  ⚠  ${change.description}');
  //       }
  //     }
  //   },
  //   onError: (errors) => errors.forEach(stderr.writeln),
  // );
}
