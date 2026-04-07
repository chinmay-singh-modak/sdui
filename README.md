# flutter_sdui_kit — Workspace

Monorepo for the Flutter SDUI toolchain. Contains the annotations, converter, and test utilities that let you convert annotated Flutter widgets into SDUI JSON schemas.

```
flutter_sdui_converter_workspace/
├── flutter_sdui_annotations/   # Lightweight annotations (regular dep in user's app)
├── flutter_sdui_converter/     # CLI + programmatic converter (dev dep in user's app)
├── flutter_sdui_test/          # Golden test utilities (dev dep in user's app)
└── flutter_sdui_kit/           # SDUI runtime framework — submodule, read-only
```

All four directories are git submodules. `flutter_sdui_kit` is an external dependency consumed by `flutter_sdui_test`; it is not developed in this workspace.

---

## Packages

| Package                    | pub.dev version | Role                                              |
| -------------------------- | --------------- | ------------------------------------------------- |
| `flutter_sdui_annotations` | `^1.0.0`        | Annotations: `@SduiComponent`, `@SduiProp`, `@SduiAction` |
| `flutter_sdui_converter`   | `^1.0.0`        | CLI + programmatic converter — scans AST, emits JSON schema |
| `flutter_sdui_test`        | `^1.0.0`        | Golden test helpers — `sduiGoldenTest()`, device presets |
| `flutter_sdui_kit`         | `^0.3.1`        | Runtime renderer — `SduiWidget`, `ActionHandler` (submodule) |

---

## Quick Start

### 1. Add dependencies to your Flutter app

```yaml
# pubspec.yaml
dependencies:
  flutter_sdui_annotations: ^1.0.0

dev_dependencies:
  flutter_sdui_converter: ^1.0.0
  flutter_sdui_test: ^1.0.0      # optional — for golden tests
```

### 2. Annotate a widget

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

  const PrimaryButton({required this.label, this.color = 'blue', this.onTap});

  @override
  Widget build(BuildContext context) { ... }
}
```

### 3. Convert

```bash
dart run flutter_sdui_converter --input . --output sdui_schema.json
```

Output:

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
        { "name": "label", "type": "string",  "required": true  },
        { "name": "color", "type": "string",  "required": false, "default": "blue" }
      ],
      "supportsAction": true
    }
  ]
}
```

---

## Submodule Setup

Clone with submodules:

```bash
git clone --recurse-submodules git@github.com:chinmay-singh-modak/flutter_sdui_kit.git
```

Or, after cloning without submodules:

```bash
git submodule update --init --recursive
```

---

## Repository Map

| Submodule                  | Remote                                                             |
| -------------------------- | ------------------------------------------------------------------ |
| `flutter_sdui_annotations` | `https://github.com/chinmay-singh-modak/flutter_sdui_annotations` |
| `flutter_sdui_converter`   | `https://github.com/chinmay-singh-modak/flutter_sdui_converter`   |
| `flutter_sdui_test`        | `https://github.com/chinmay-singh-modak/flutter_sdui_test`        |
| `flutter_sdui_kit`         | `https://github.com/chinmay-singh-modak/flutter_sdui_kit`         |

---

## License

MIT — see each package's `LICENSE` file.
