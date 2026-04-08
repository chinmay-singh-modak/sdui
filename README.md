# flutter_sdui_kit — Workspace

Monorepo for the Flutter SDUI toolchain. Contains the annotations, converter, and test utilities that let you convert annotated Flutter widgets into SDUI JSON schemas.

```
flutter_sdui_converter_workspace/
├── packages/
│   ├── flutter_sdui_annotations/   # Lightweight annotations (regular dep in user's app)
│   ├── flutter_sdui_converter/     # CLI + programmatic converter (dev dep in user's app)
│   ├── flutter_sdui_test/          # Golden test utilities (dev dep in user's app)
│   └── flutter_sdui_kit/           # SDUI runtime framework
└── melos.yaml
```

All four packages live under `packages/` in this monorepo and are managed with [Melos](https://melos.invertase.dev/).

---

## Packages

| Package                    | pub.dev version | Role                                              |
| -------------------------- | --------------- | ------------------------------------------------- |
| `flutter_sdui_annotations` | `^1.0.0`        | Annotations: `@SduiComponent`, `@SduiProp`, `@SduiAction` |
| `flutter_sdui_converter`   | `^1.0.0`        | CLI + programmatic converter — scans AST, emits JSON schema |
| `flutter_sdui_test`        | `^1.0.0`        | Golden test helpers — `sduiGoldenTest()`, device presets |
| `flutter_sdui_kit`         | `^0.3.1`        | Runtime renderer — `SduiWidget`, `ActionHandler`             |

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

## Cloning

```bash
git clone git@github.com:chinmay-singh-modak/sdui_workspace.git
cd sdui_workspace
dart pub global activate melos
melos bootstrap
```

---

## Repository

All packages are in a single repo: [chinmay-singh-modak/sdui_workspace](https://github.com/chinmay-singh-modak/sdui_workspace)

| Package                    | Path in repo                          | pub.dev |
| -------------------------- | ------------------------------------- | ------- |
| `flutter_sdui_annotations` | `packages/flutter_sdui_annotations/` | [pub.dev/packages/flutter_sdui_annotations](https://pub.dev/packages/flutter_sdui_annotations) |
| `flutter_sdui_converter`   | `packages/flutter_sdui_converter/`   | [pub.dev/packages/flutter_sdui_converter](https://pub.dev/packages/flutter_sdui_converter) |
| `flutter_sdui_test`        | `packages/flutter_sdui_test/`        | [pub.dev/packages/flutter_sdui_test](https://pub.dev/packages/flutter_sdui_test) |
| `flutter_sdui_kit`         | `packages/flutter_sdui_kit/`         | [pub.dev/packages/flutter_sdui_kit](https://pub.dev/packages/flutter_sdui_kit) |

---

## License

MIT — see each package's `LICENSE` file.
