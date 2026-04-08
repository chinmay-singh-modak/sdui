# flutter_sdui — Workspace

Monorepo for the Flutter SDUI toolchain. Annotate your widgets, convert them to a JSON schema, render them server-side, and verify with golden tests — all from one place.

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

## How the packages connect

```text
1. Annotate widgets       flutter_sdui_annotations
         ↓
2. Generate JSON schema   flutter_sdui_converter
         ↓
3. Render at runtime      flutter_sdui_kit   ← your server sends the JSON
         ↓
4. Verify visually        flutter_sdui_test  ← golden diff: native vs SDUI
```

## Packages

| Package | Version | Role | pub.dev |
| ------- | ------- | ---- | ------- |
| [`flutter_sdui_annotations`](packages/flutter_sdui_annotations/) | `^1.0.0` | Mark widgets with `@SduiComponent`, `@SduiProp`, `@SduiAction` | [pub.dev](https://pub.dev/packages/flutter_sdui_annotations) |
| [`flutter_sdui_converter`](packages/flutter_sdui_converter/) | `^1.0.0` | Scan annotated widgets, emit JSON schema | [pub.dev](https://pub.dev/packages/flutter_sdui_converter) |
| [`flutter_sdui_kit`](packages/flutter_sdui_kit/) | `^0.3.1` | Runtime renderer — `SduiWidget`, `ActionHandler` | [pub.dev](https://pub.dev/packages/flutter_sdui_kit) |
| [`flutter_sdui_test`](packages/flutter_sdui_test/) | `^1.0.0` | Golden test helpers — `sduiGoldenTest()`, device presets | [pub.dev](https://pub.dev/packages/flutter_sdui_test) |

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
git clone git@github.com:chinmay-singh-modak/sdui.git
cd sdui
dart pub global activate melos
melos bootstrap
```

---

## License

MIT — see each package's `LICENSE` file.
