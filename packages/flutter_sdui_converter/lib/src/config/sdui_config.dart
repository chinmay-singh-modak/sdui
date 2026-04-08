class SduiConfig {
  final String version;
  final String outputPath;
  final ScanConfig scan;
  final FeatureFlags flags;

  const SduiConfig({
    this.version = '1.0.0',
    this.outputPath = 'sdui_schema.json',
    this.scan = const ScanConfig(),
    this.flags = const FeatureFlags(),
  });

  SduiConfig copyWith({
    String? version,
    String? outputPath,
    ScanConfig? scan,
    FeatureFlags? flags,
  }) =>
      SduiConfig(
        version: version ?? this.version,
        outputPath: outputPath ?? this.outputPath,
        scan: scan ?? this.scan,
        flags: flags ?? this.flags,
      );
}

class ScanConfig {
  final List<String> include;
  final List<String> exclude;

  const ScanConfig({
    this.include = const ['lib/**'],
    this.exclude = const [],
  });
}

class FeatureFlags {
  final bool strictMode;
  final bool generateTypes;

  const FeatureFlags({
    this.strictMode = false,
    this.generateTypes = false,
  });

  FeatureFlags copyWith({bool? strictMode, bool? generateTypes}) => FeatureFlags(
        strictMode: strictMode ?? this.strictMode,
        generateTypes: generateTypes ?? this.generateTypes,
      );
}
