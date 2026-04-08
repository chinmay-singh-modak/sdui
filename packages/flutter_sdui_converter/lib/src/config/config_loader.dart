import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'sdui_config.dart';

class ConfigLoader {
  /// Loads config from [projectPath]/flutter_sdui.yaml.
  /// Falls back to defaults silently if the file is absent.
  /// Merges [cliOverrides] on top — CLI always wins.
  Future<SduiConfig> load(String projectPath, {SduiConfig? cliOverrides}) async {
    final file = File(p.join(projectPath, 'flutter_sdui.yaml'));
    SduiConfig config;

    if (await file.exists()) {
      final content = await file.readAsString();
      config = _parse(content);
    } else {
      config = const SduiConfig();
    }

    if (cliOverrides != null) {
      config = _merge(config, cliOverrides);
    }

    return config;
  }

  SduiConfig _parse(String yamlContent) {
    final doc = loadYaml(yamlContent);
    if (doc == null) return const SduiConfig();

    final map = doc as YamlMap;

    final version = map['version'] as String? ?? '1.0.0';
    _validateSemver(version);

    final outputPath = map['output'] as String? ?? 'sdui_schema.json';

    final scanMap = map['scan'] as YamlMap?;
    final scan = scanMap != null ? _parseScan(scanMap) : const ScanConfig();

    final flagsMap = map['flags'] as YamlMap?;
    final flags = flagsMap != null ? _parseFlags(flagsMap) : const FeatureFlags();

    return SduiConfig(
      version: version,
      outputPath: outputPath,
      scan: scan,
      flags: flags,
    );
  }

  ScanConfig _parseScan(YamlMap map) {
    final include = (map['include'] as YamlList?)
            ?.map((e) => e.toString())
            .toList() ??
        const ['lib/'];

    final exclude = (map['exclude'] as YamlList?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return ScanConfig(include: include, exclude: exclude);
  }

  FeatureFlags _parseFlags(YamlMap map) => FeatureFlags(
        strictMode: map['strict_mode'] as bool? ?? false,
        generateTypes: map['generate_types'] as bool? ?? false,
      );

  /// Merges [overrides] on top of [base]. Only non-default override values win.
  /// Since we can't distinguish "explicitly set" from "default" without a
  /// sentinel, CLI callers pass a config containing only the fields they set
  /// and rely on copyWith for the rest.
  SduiConfig _merge(SduiConfig base, SduiConfig overrides) => SduiConfig(
        version: overrides.version != '1.0.0' ? overrides.version : base.version,
        outputPath: overrides.outputPath != 'sdui_schema.json'
            ? overrides.outputPath
            : base.outputPath,
        scan: ScanConfig(
          include: overrides.scan.include.isNotEmpty &&
                  overrides.scan.include != const ['lib/']
              ? overrides.scan.include
              : base.scan.include,
          exclude: overrides.scan.exclude.isNotEmpty
              ? overrides.scan.exclude
              : base.scan.exclude,
        ),
        flags: FeatureFlags(
          strictMode: overrides.flags.strictMode || base.flags.strictMode,
          generateTypes:
              overrides.flags.generateTypes || base.flags.generateTypes,
        ),
      );

  static final _semver =
      RegExp(r'^\d+\.\d+\.\d+(-[a-zA-Z0-9.]+)?(\+[a-zA-Z0-9.]+)?$');

  void _validateSemver(String version) {
    if (!_semver.hasMatch(version)) {
      throw FormatException(
          'Invalid version "$version" in flutter_sdui.yaml — must be semver (e.g. 1.0.0)');
    }
  }
}
