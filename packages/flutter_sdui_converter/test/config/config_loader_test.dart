import 'dart:io';

import 'package:flutter_sdui_converter/flutter_sdui_converter.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:flutter_sdui_converter/src/config/config_loader.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sdui_config_test');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('ConfigLoader', () {
    test('returns defaults when no yaml file exists', () async {
      final loader = ConfigLoader();
      final config = await loader.load(tempDir.path);
      expect(config.outputPath, 'sdui_schema.json');
      expect(config.scan.include, ['lib/**']);
      expect(config.flags.strictMode, false);
    });

    test('loads version, output, and flags from yaml', () async {
      final yaml = '''
version: "2.1.0"
output: "out/schema.json"
flags:
  strict_mode: true
  generate_types: true
''';
      File(p.join(tempDir.path, 'flutter_sdui.yaml'))
          .writeAsStringSync(yaml);

      final config = await ConfigLoader().load(tempDir.path);
      expect(config.version, '2.1.0');
      expect(config.outputPath, 'out/schema.json');
      expect(config.flags.strictMode, true);
      expect(config.flags.generateTypes, true);
    });

    test('loads scan include/exclude from yaml', () async {
      final yaml = '''
version: "1.0.0"
scan:
  include:
    - lib/components
    - lib/widgets
  exclude:
    - lib/generated
''';
      File(p.join(tempDir.path, 'flutter_sdui.yaml'))
          .writeAsStringSync(yaml);

      final config = await ConfigLoader().load(tempDir.path);
      expect(config.scan.include, ['lib/components', 'lib/widgets']);
      expect(config.scan.exclude, ['lib/generated']);
    });

    test('CLI overrides win over yaml', () async {
      File(p.join(tempDir.path, 'flutter_sdui.yaml'))
          .writeAsStringSync('version: "1.0.0"\noutput: "from_yaml.json"');

      final overrides = SduiConfig(outputPath: 'from_cli.json');
      final config = await ConfigLoader().load(tempDir.path, cliOverrides: overrides);
      expect(config.outputPath, 'from_cli.json');
    });

    test('throws on invalid semver version', () async {
      File(p.join(tempDir.path, 'flutter_sdui.yaml'))
          .writeAsStringSync('version: "not-semver"');

      expect(
        () => ConfigLoader().load(tempDir.path),
        throwsA(isA<FormatException>()),
      );
    });

    test('strict flag from CLI overrides yaml false', () async {
      File(p.join(tempDir.path, 'flutter_sdui.yaml'))
          .writeAsStringSync('version: "1.0.0"');

      final overrides =
          SduiConfig(flags: FeatureFlags(strictMode: true));
      final config =
          await ConfigLoader().load(tempDir.path, cliOverrides: overrides);
      expect(config.flags.strictMode, true);
    });
  });
}
