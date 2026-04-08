import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_sdui_converter/flutter_sdui_converter.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('input',
        abbr: 'i',
        help: 'Path to the Flutter project root.',
        mandatory: true)
    ..addOption('output',
        abbr: 'o',
        help: 'Output JSON file path.',
        defaultsTo: 'sdui_schema.json')
    ..addOption('previous',
        abbr: 'p',
        help: 'Path to a previous schema JSON for breaking-change detection.')
    ..addFlag('strict',
        help: 'Fail on unknown Dart types instead of falling back to "any".',
        defaultsTo: false,
        negatable: false)
    ..addFlag('watch',
        abbr: 'w',
        help: 'Re-run on .dart file changes.',
        defaultsTo: false,
        negatable: false)
    ..addFlag('help',
        abbr: 'h',
        help: 'Show this help message.',
        defaultsTo: false,
        negatable: false);

  ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    stderr.writeln(parser.usage);
    exitCode = 1;
    return;
  }

  if (args['help'] as bool) {
    stdout.writeln('flutter_sdui_converter — Convert annotated Flutter widgets to SDUI JSON\n');
    stdout.writeln(parser.usage);
    return;
  }

  final projectPath = args['input'] as String;
  final outputPath = args['output'] as String;
  final strict = args['strict'] as bool;
  final watch = args['watch'] as bool;
  final previousPath = args['previous'] as String?;

  SduiSchema? previousSchema;
  if (previousPath != null) {
    final file = File(previousPath);
    if (!await file.exists()) {
      stderr.writeln('Error: previous schema file not found: $previousPath');
      exitCode = 1;
      return;
    }
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    previousSchema = SduiSchema.fromJson(json);
  }

  final config = SduiConfig(
    outputPath: outputPath,
    flags: FeatureFlags(strictMode: strict),
  );

  Future<bool> runOnce() async {
    final result = await SduiConverter.convert(
      projectPath: projectPath,
      config: config,
      previousSchema: previousSchema,
    );

    return await result.map<Future<bool>>(
      onSuccess: (schema) async {
        // Print diff warnings if applicable
        final diff = schema.diff;
        if (diff != null && diff.hasChanges) {
          if (diff.hasBreakingChanges) {
            stderr.writeln('\nBreaking changes detected:');
            for (final c in diff.breaking) {
              stderr.writeln('  ⚠  $c');
            }
          }
          if (diff.nonBreaking.isNotEmpty) {
            stdout.writeln('\nNon-breaking changes:');
            for (final c in diff.nonBreaking) {
              stdout.writeln('  ✓  $c');
            }
          }
        }

        final emitter = JsonEmitter();
        await emitter.writeToFile(schema, outputPath);

        final count = schema.components.length;
        stdout.writeln(
            'Generated $outputPath — $count component${count == 1 ? '' : 's'}');

        if (diff != null && diff.hasBreakingChanges && strict) {
          stderr.writeln(
              '\nStrict mode: breaking changes are a hard error. '
              'Bump version in flutter_sdui.yaml to continue.');
          return false;
        }
        return true;
      },
      onError: (errors) async {
        stderr.writeln('Conversion failed with ${errors.length} error(s):');
        for (final e in errors) {
          stderr.writeln('  $e');
        }
        return false;
      },
    );
  }

  if (!watch) {
    final ok = await runOnce();
    exitCode = ok ? 0 : 1;
    return;
  }

  // Watch mode
  stdout.writeln('Watching $projectPath for changes… (Ctrl+C to stop)');
  await runOnce();

  final dir = Directory(projectPath);
  await for (final _ in dir
      .watch(recursive: true)
      .where((e) => e.path.endsWith('.dart'))) {
    // Debounce: small delay to let file writes settle
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await runOnce();
  }
}
