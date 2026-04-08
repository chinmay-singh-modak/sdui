# flutter_sdui_converter

Scans an annotated Flutter project and emits a single SDUI (Server-Driven UI) JSON schema file. Works fully offline — no auth, no backend required.

Add as a `dev_dependency` in your app. The built-in CLI and the programmatic API are both supported.

> **Step 2 of 4 in the flutter_sdui toolchain.**
> [`flutter_sdui_annotations`](https://pub.dev/packages/flutter_sdui_annotations) marks your widgets → **this package** scans them and emits a JSON schema → [`flutter_sdui_kit`](https://pub.dev/packages/flutter_sdui_kit) renders that JSON at runtime → [`flutter_sdui_test`](https://pub.dev/packages/flutter_sdui_test) verifies it visually.

---

## Installation

```yaml
# pubspec.yaml
dependencies:
  flutter_sdui_annotations: ^1.0.0

dev_dependencies:
  flutter_sdui_converter: ^1.0.0
```

---

## CLI usage

```bash
# Convert the whole project, write to sdui_schema.json
dart run flutter_sdui_converter --input . --output sdui_schema.json

# Watch mode — re-runs on every .dart file change
dart run flutter_sdui_converter --input . --output sdui_schema.json --watch

# Enable strict mode (unknown Dart types → hard error)
dart run flutter_sdui_converter --input . --strict

# Detect breaking changes against a previous schema
dart run flutter_sdui_converter --input . --previous sdui_schema_v1.json
```

### CLI flags

| Flag         | Description                                          | Default            |
| ------------ | ---------------------------------------------------- | ------------------ |
| `--input`    | Path to the Flutter project root (required)          | —                  |
| `--output`   | Output file path (overrides `flutter_sdui.yaml`)     | `sdui_schema.json` |
| `--watch`    | Re-run on `.dart` file changes                       | off                |
| `--strict`   | Fail on unknown Dart types instead of falling back   | off                |
| `--previous` | Path to a previous schema file for diff/comparison   | —                  |

---

## Programmatic API

```dart
import 'package:flutter_sdui_converter/flutter_sdui_converter.dart';

// Auto-discovers flutter_sdui.yaml in projectPath
final result = await SduiConverter.convert(
  projectPath: '/path/to/flutter/project',
);

// With programmatic config override
final result = await SduiConverter.convert(
  projectPath: '/path/to/flutter/project',
  config: SduiConfig(
    outputPath: 'sdui_schema.json',
    scan: ScanConfig(include: ['lib/components']),
    flags: FeatureFlags(strictMode: true),
  ),
  previousSchema: SduiSchema.fromJson(previousJson), // optional diff
);

result.fold(
  onSuccess: (SduiSchema schema) {
    // Write file, upload to backend, diff — your choice
    print(JsonEmitter().emit(schema));
  },
  onError: (List<SduiConvertError> errors) {
    for (final e in errors) print(e.message);
  },
);
```

---

## Config file — flutter_sdui.yaml

Place at your Flutter project root. All fields are optional — the converter uses defaults if the file is absent.

```yaml
# flutter_sdui.yaml
version: "1.0.0"

output: "sdui_schema.json"

scan:
  include:
    - lib/components
    - lib/widgets
  exclude:
    - lib/generated
    - "**/*.g.dart"
    - "**/*.freezed.dart"

flags:
  strict_mode: false
  generate_types: false
```

Config resolution priority (highest to lowest):

1. CLI flags
2. `flutter_sdui.yaml` in project root
3. Built-in defaults

---

## Output schema shape

```json
{
  "schemaVersion": "1.0.0",
  "generatedAt": "2025-01-01T00:00:00.000Z",
  "generatedBy": "flutter_sdui_converter",
  "converterVersion": "1.0.0",
  "components": [
    {
      "type": "PrimaryButton",
      "props": [
        { "name": "label",  "type": "string",  "required": true  },
        { "name": "color",  "type": "string",  "required": false, "default": "blue" }
      ],
      "supportsAction": true
    }
  ]
}
```

### Dart type → SDUI type mapping

| Dart type                    | SDUI type                            |
| ---------------------------- | ------------------------------------ |
| `String`                     | `string`                             |
| `int`                        | `integer`                            |
| `double`                     | `number`                             |
| `num`                        | `number`                             |
| `bool`                       | `boolean`                            |
| `List<T>`                    | `array`                              |
| `Map<K, V>`                  | `object`                             |
| `Color`                      | `color`                              |
| `VoidCallback` / `Function`  | action (sets `supportsAction: true`) |
| Unknown                      | `any`                                |

In `strict_mode: true`, unknown types are hard errors instead of falling back to `any`.

---

## Breaking change detection

Supply a previous schema to get a structured diff:

```bash
dart run flutter_sdui_converter --input . --previous sdui_schema_v1.json
```

| Change                        | Breaking |
| ----------------------------- | -------- |
| Prop removed                  | Yes      |
| Prop type changed             | Yes      |
| Required prop added           | Yes      |
| Prop became required          | Yes      |
| Action support removed        | Yes      |
| Component removed             | Yes      |
| Component renamed             | Yes      |
| New optional prop added       | No       |
| New component added           | No       |
| Default value added to prop   | No       |
| Action support added          | No       |
| Prop order changed            | No       |

In `strict_mode`, breaking changes exit non-zero. Otherwise they print as warnings and conversion succeeds.

---

## Pipeline

```text
FileScanner  →  ComponentParser  →  SchemaTransformer  →  (SchemaDiffer)  →  JsonEmitter
   globs           AST / analyzer       type mapping         optional diff       JSON string
```

Each stage is an independent class with a single public method. No I/O in the parser or transformer — only in the scanner and emitter.

The emitted JSON is consumed at runtime by [`flutter_sdui_kit`](https://pub.dev/packages/flutter_sdui_kit)'s `SduiWidget`. Use the schema files as fixtures with [`flutter_sdui_test`](https://pub.dev/packages/flutter_sdui_test) to verify rendering.

---

## Part of the flutter_sdui workspace

This package is developed in the [chinmay-singh-modak/sdui_workspace](https://github.com/chinmay-singh-modak/sdui_workspace) monorepo alongside the rest of the toolchain.

| Package | Role | pub.dev |
| ------- | ---- | ------- |
| `flutter_sdui_annotations` | Annotations | [pub.dev/packages/flutter_sdui_annotations](https://pub.dev/packages/flutter_sdui_annotations) |
| `flutter_sdui_converter` | CLI + programmatic converter (this package) | [pub.dev/packages/flutter_sdui_converter](https://pub.dev/packages/flutter_sdui_converter) |
| `flutter_sdui_test` | Golden test utilities | [pub.dev/packages/flutter_sdui_test](https://pub.dev/packages/flutter_sdui_test) |
| `flutter_sdui_kit` | SDUI runtime renderer (`SduiWidget`) | [pub.dev/packages/flutter_sdui_kit](https://pub.dev/packages/flutter_sdui_kit) |
