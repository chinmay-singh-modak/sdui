# flutter_sdui_kit — Claude Code Context

**GitHub repo:** `git@github.com:chinmay-singh-modak/flutter_sdui_kit.git`

## Project Overview

A standalone Dart tool that converts annotated Flutter widgets into SDUI (Server-Driven UI) JSON schemas. Fully decoupled from any backend — works offline, no auth required.

### Three-package workspace

```
flutter_sdui_converter_workspace/
├── flutter_sdui_annotations/   # Lightweight annotations (regular dep in user's app)
├── flutter_sdui_converter/     # Heavy converter tool (dev dep in user's app)
└── flutter_sdui_test/          # Golden test utilities for SDUI vs native comparison
```

---

## Package: flutter_sdui_annotations

### Purpose

Provides annotations that Flutter developers apply to their widgets. No analyzer dependency — must stay lightweight so it's safe as a regular `dependency`.

### Annotations

- `@SduiComponent(name: String)` — marks a widget as an SDUI component
- `@SduiProp({dynamic defaultValue})` — marks a constructor field as an SDUI prop
- `@SduiAction()` — marks a callback field as an SDUI action

### Rules

- Zero dependencies beyond `meta`
- No dart:analyzer usage ever
- Pure Dart, no Flutter SDK dependency

---

## Package: flutter_sdui_converter

### Purpose

Scans a Flutter project directory, finds all files with `@SduiComponent` annotated widgets, parses the AST, and emits a single SDUI JSON schema file.

### Internal structure

```
lib/src/
├── config/              # flutter_sdui.yaml loader + SduiConfig model
├── annotations/         # Mirror of annotation shapes (for AST matching, not runtime)
├── scanner/             # Finds .dart files using ScanConfig globs
├── parser/              # dart:analyzer AST traversal — extracts component metadata
├── transformer/         # Converts raw AST data into SduiSchema model objects
├── emitter/             # Serializes SduiSchema models → JSON string
└── models/              # SduiSchema, SduiComponent, SduiProp, SduiAction
bin/
└── flutter_sdui_converter.dart   # CLI entrypoint (dart run flutter_sdui_converter)
```

### Key dependencies

- `analyzer` — Dart AST parsing
- `glob` — file scanning
- `args` — CLI argument parsing
- `json_serializable` + `build_runner` — model serialization (dev dep)

### CLI usage (target)

```bash
# Convert whole project, output to sdui_schema.json
dart run flutter_sdui_converter --input . --output sdui_schema.json

# Watch mode
dart run flutter_sdui_converter --input . --output sdui_schema.json --watch
```

---

## Output JSON Schema Shape

```json
{
  "schemaVersion": "1.0.0",
  "generatedAt": "2025-01-01T00:00:00Z",
  "generatedBy": "flutter_sdui_converter",
  "converterVersion": "1.0.0",
  "components": [
    {
      "name": "PrimaryButton",
      "props": [
        { "name": "label", "type": "string", "required": true },
        { "name": "color", "type": "string", "required": false, "default": "blue" }
      ],
      "actions": [
        { "name": "onTap" }
      ]
    }
  ]
}
```

### Metadata fields

| Field | Source | Description |
|-------|--------|-------------|
| `schemaVersion` | `flutter_sdui.yaml` → `version` | Dev-controlled, represents the schema's version |
| `generatedAt` | Auto-stamped at conversion time | ISO 8601 UTC timestamp |
| `generatedBy` | Hardcoded constant | Always `"flutter_sdui_converter"` |
| `converterVersion` | Package version from `pubspec.yaml` | Which version of the converter produced this schema |

### Why two version fields

- `schemaVersion` — tracks the **content**. Dev bumps this when components change.
- `converterVersion` — tracks the **tool**. Useful when the JSON shape itself evolves between converter releases. Vyne backend can use this to apply compatibility handling.

---

## Programmatic API (Primary Use Case)

`flutter_sdui_converter` is a **library first**. The built-in CLI is secondary — the primary consumer is the Vyne CLI (a separate package) which calls the converter programmatically.

### Public API surface

```dart
// Single entry point
import 'package:flutter_sdui_converter/flutter_sdui_converter.dart';

// Auto-discovers flutter_sdui.yaml in projectPath
final result = await SduiConverter.convert(
  projectPath: '/path/to/flutter/project',
);

// Programmatic config override (Vyne CLI uses this)
final result = await SduiConverter.convert(
  projectPath: '/path/to/flutter/project',
  config: SduiConfig(
    outputPath: 'sdui_schema.json',
    scan: ScanConfig(include: ['lib/components']),
    flags: FeatureFlags(strictMode: true),
  ),
);

result.fold(
  onSuccess: (SduiSchema schema) {
    // Vyne CLI: upload to backend, diff, write file — its choice
  },
  onError: (List<SduiConvertError> errors) {
    // Surface in CLI output
  },
);
```

### Design rules for the public API

- `SduiConverter.convert()` is the single public entry point
- `SduiConfig` is constructable both from YAML and programmatically — CLI args always win
- `SduiSchema` is a fully serializable model — the caller decides what to do with it
- No `dart:io` in core logic (parser, transformer, emitter models) — only in scanner and file emitter
- Vyne CLI can ignore the built-in file emitter entirely and handle output itself

### How Vyne CLI consumes this

```
vyne publish
  → reads flutter_sdui.yaml from cwd
  → calls SduiConverter.convert(projectPath: cwd)
  → receives SduiSchema
  → diffs against last published schema version
  → uploads to Vyne backend via API
```

```yaml
# Vyne CLI pubspec.yaml
dev_dependencies:
  flutter_sdui_converter: ^1.0.0
```

---

## How a Standalone Developer Uses This

### 1. Add dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_sdui_annotations: ^1.0.0

dev_dependencies:
  flutter_sdui_converter: ^1.0.0
```

### 2. Annotate widgets

```dart
import 'package:flutter_sdui_annotations/flutter_sdui_annotations.dart';

@SduiComponent(name: 'PrimaryButton')
class PrimaryButton extends StatelessWidget {
  @SduiProp()
  final String label;

  @SduiProp(defaultValue: 'blue')
  final String color;

  @SduiAction()
  final VoidCallback? onTap;

  const PrimaryButton({
    required this.label,
    this.color = 'blue',
    this.onTap,
  });
}
```

### 3. Run converter

```bash
dart run flutter_sdui_converter --input lib/ --output sdui_schema.json
```

---

## Dart Type → SDUI Type Mapping

| Dart Type | SDUI Type |
|-----------|-----------|
| `String` | `string` |
| `int` | `integer` |
| `double` | `number` |
| `bool` | `boolean` |
| `List<T>` | `array` |
| `Map<K,V>` | `object` |
| `Color` | `color` |
| `VoidCallback` / `Function` | → action (not a prop) |
| Unknown | `any` |

---

## Schema Versioning & Breaking Change Detection

Versioning is handled at three layers — each with a distinct responsibility.

### Layer 1 — flutter_sdui.yaml (manual, dev-controlled)

Dev manually bumps `version` on breaking changes:

```yaml
version: "2.0.0"
```

This version is stamped into the output JSON:

```json
{ "version": "2.0.0", "generatedAt": "...", "components": [...] }
```

### Layer 2 — flutter_sdui_converter (breaking change detection)

Converter compares current schema against a previous schema file if provided. Emits structured warnings or hard errors depending on `strict_mode`.

```dart
final result = await SduiConverter.convert(
  projectPath: '/path/to/project',
  previousSchema: SduiSchema.fromJson(previousJson), // optional
);
```

If `previousSchema` is supplied, the converter runs a `SchemaDiffer` pass before emitting:

```
⚠  Breaking changes detected in PrimaryButton:
   - prop 'color' type changed: string → enum
   - prop 'icon' removed
   - required prop 'size' added (existing consumers won't send it)

   Bump version in flutter_sdui.yaml to continue.
```

In `strict_mode: true` — breaking changes are hard errors (non-zero exit).
In `strict_mode: false` — breaking changes are warnings, conversion still succeeds.

### Layer 3 — Vyne CLI (full version history)

Vyne CLI fetches the last published schema from the backend and passes it as `previousSchema`. This is a paid cloud feature — standalone users only get local diff if they manually supply the previous file.

```
vyne publish
  → convert(projectPath, previousSchema: lastPublished)
  → if breaking changes → prompt dev to confirm or abort
  → tag new version, upload to backend
  → old version retained for rollback
```

### SchemaDiffer — what counts as breaking

| Change | Breaking? |
|--------|-----------|
| Prop removed | ✅ Yes |
| Prop type changed | ✅ Yes |
| Required prop added | ✅ Yes |
| Component removed | ✅ Yes |
| Component renamed | ✅ Yes |
| New optional prop added | ❌ No |
| New component added | ❌ No |
| Default value added to existing prop | ❌ No |
| Prop order changed | ❌ No |

### SchemaDiffer location

`lib/src/differ/schema_differ.dart`

```dart
class SchemaDiffer {
  SchemaDiff diff(SduiSchema previous, SduiSchema current);
}

class SchemaDiff {
  final List<BreakingChange> breaking;
  final List<NonBreakingChange> nonBreaking;
  bool get hasBreakingChanges => breaking.isNotEmpty;
}
```

### Updated build order with differ

1. `flutter_sdui_annotations`
2. `models/` — includes `SchemaDiff`, `BreakingChange`, `NonBreakingChange`
3. `config/`
4. `scanner/`
5. `parser/`
6. `transformer/`
7. `differ/` — pure function, no IO
8. `emitter/`
9. `bin/flutter_sdui_converter.dart`

---

## Coding Conventions

- Prefer `Result<T, E>` pattern over throwing exceptions in parser/transformer
- Each pipeline stage (scanner → parser → transformer → emitter) is a separate class with a single public method
- Models are immutable (`final` fields, `const` constructors where possible)
- All file I/O happens only in scanner and emitter — parser and transformer are pure functions
- Tests live in `test/` mirroring `lib/src/` structure

---

## Build Order

See **Schema Versioning & Breaking Change Detection** section above for the full updated build order including the `differ/` module.

---

## Config File — flutter_sdui.yaml

Placed at the root of the user's Flutter project. Loaded automatically by the converter before scanning.

### Full config shape

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
  strict_mode: true       # fail on unknown Dart types instead of falling back to 'any'
  generate_types: true    # emit typed prop schema with constraints
```

### Config resolution priority (highest → lowest)

1. CLI flags (e.g. `--output`) — always win
2. `flutter_sdui.yaml` in project root
3. Defaults baked into `SduiConfig`

### SduiConfig model

```dart
class SduiConfig {
  final String version;
  final String outputPath;          // default: 'sdui_schema.json'
  final ScanConfig scan;
  final FeatureFlags flags;
}

class ScanConfig {
  final List<String> include;       // default: ['lib/']
  final List<String> exclude;       // default: ['**/*.g.dart', '**/*.freezed.dart']
}

class FeatureFlags {
  final bool strictMode;            // default: false
  final bool generateTypes;         // default: false
}
```

### ConfigLoader responsibilities

- Looks for `flutter_sdui.yaml` in the project root (input directory)
- If not found, silently uses defaults — config file is optional
- Validates `version` is a valid semver string
- Merges CLI-provided overrides on top after loading
- Lives at `lib/src/config/config_loader.dart`

### How flags affect the pipeline

| Flag | Off (default) | On |
|------|--------------|-----|
| `strict_mode` | Unknown Dart types → `any`, emits warning | Unknown Dart types → hard error, exits non-zero |
| `generate_types` | `"type": "string"` | `"type": "string", "constraints": { "minLength": 0 }` |

### Scan globs

- Uses `package:glob` for include/exclude pattern matching
- Exclude patterns are applied after include — exclude always wins
- Auto-excludes `**/*.g.dart` and `**/*.freezed.dart` even if user doesn't specify

---

## What This Is NOT

- Not tied to any backend or cloud service
- Not a build_runner builder (yet — possible future extension)
- Not a Flutter SDK package — pure Dart tool
- Not responsible for serving or hosting the JSON — just generates it

---

## Package: flutter_sdui_test

### What it does

Testing utility package that wraps Flutter's golden testing infrastructure with
SDUI-aware helpers. A developer drops it in `dev_dependencies`, calls
`sduiGoldenTest()`, and gets a side-by-side visual comparison of native vs
SDUI-rendered output with zero boilerplate.

### flutter_sdui_test structure

```text
lib/
  flutter_sdui_test.dart        # barrel export (public API only)
  src/
    golden_test.dart            # sduiGoldenTest() implementation
    schema_loader.dart          # SduiTestSchema
    device_presets.dart         # SduiDevices constants + SduiDevice model
    diff_reporter.dart          # failure output formatting
    font_config.dart            # test font setup to prevent false positives
```

### flutter_sdui_test API

```dart
// Primary test utility — registers a testWidgets group per device
sduiGoldenTest(
  'screen name',
  nativeWidget: LoginScreen(),
  schemaPath: 'path/to/login.json',  // file-system path to JSON
  // OR
  schema: {'screen': 'login', 'body': {...}},  // inline map
  devices: [SduiDevices.phone],      // optional, defaults to phone
  threshold: 0.01,                   // optional diff threshold (0.0–1.0)
);

// Device presets
SduiDevices.phone   // 390×844 (iPhone 14)
SduiDevices.tablet  // 820×1180 (iPad Air)
SduiDevices.small   // 360×800  (Android compact)

// Schema loader (for manual test setup)
SduiTestSchema.fromPath('path/to/screen.json')
SduiTestSchema.fromJson(Map<String, dynamic> json)
```

### Golden file naming

```text
test/goldens/
  {test_name}_{device}_native.png
  {test_name}_{device}_sdui.png
```

Paths are relative to the test file calling `sduiGoldenTest`.

### flutter_sdui_test dependencies

- `flutter_test` (sdk) — widget test infrastructure
- `flutter_sdui_kit` (git) — `SduiWidget` renderer
- `alchemist: ^0.7.0` (dev dep only) — used in this package's own tests

### Implementation rules

- `sduiGoldenTest` calls `group()` then `testWidgets()` per device — no custom test runner
- Font: always wrap pumped widgets with `sduiTestTheme()` which uses `'Ahem'` font
- Surface size: always call `tester.binding.setSurfaceSize(device.size)` and tear down
- Threshold: install a custom `goldenFileComparator` scoped to the test, restore in `addTearDown`
- `SduiWidget` from `flutter_sdui_kit` takes a JSON string — `SduiTestSchema` provides `toJsonString()`
- No dart:io in `schema_loader` when loading from a Map; use dart:io only for file path loading

### flutter_sdui_test usage

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_sdui_test:
    git:
      url: git@github.com:chinmay-singh-modak/flutter_sdui_kit.git
      path: packages/flutter_sdui_test
```

```dart
void main() {
  sduiGoldenTest(
    'login screen',
    nativeWidget: const LoginScreen(),
    schemaPath: 'test/fixtures/login.json',
  );
}
```

```bash
flutter test --update-goldens   # generate
flutter test                    # compare
```
